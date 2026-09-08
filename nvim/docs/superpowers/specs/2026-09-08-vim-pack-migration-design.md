# vim.pack migration — design

**Date:** 2026-09-08
**Status:** implemented and verified 2026-09-08; awaiting the maintainer's own testing
**Scope:** Spec 1 of 3. Structural migration from lazy.nvim to `vim.pack`, plus
defect fixes that can be justified by a quotable source.

Specs 2 (0.12 native modernization) and 3 (IDE capability audit) are deliberately
out of scope here and get their own cycles. Rationale in *Decomposition* below.

---

## 1. Context

### Current state

| | |
|---|---|
| Neovim | 0.12.5 (`LuaJIT 2.1.1788460057`) |
| Plugin manager | lazy.nvim, bootstrapped in `lua/config/lazy.lua` |
| Plugins | 48 (49 in `lazy-lock.json` including lazy.nvim itself) |
| Spec files | 22 under `lua/config/plugins/`, auto-imported via 5 `import` globs |
| `config` functions | 19 |
| `dependencies` lists | 18, nested, ordering implicit |
| Lazy triggers | 13 `event`, 2 `cmd`, 1 `keys`, 2 `lazy` |
| `build` hooks | 3 |
| Startup baseline | **198 ms** (3 runs through a pty). An earlier 110 ms figure came from headless `-c q`, which exits before the config finishes settling and is not comparable. |
| VCS | none at migration start; `git init` + baseline commit `5b57b3c` created as step 0 |
| Backup | `~/Downloads/dotfile_hyperland` → `git@github.com:bboysidou/dotfile_hyperland.git`, clean, `nvim/` byte-identical to live config, separate inodes (manual copy sync) |

### Capability gap

`vim.pack` on 0.12.5 provides `add`, `get`, `update`, `del` and nothing else.
Verified absent by probing the running binary:

```
vim.fn.exists(':packupdate')  -> 0
vim.fn.exists('+packlockfile') -> 0
```

The `:packupdate` / `:packdel` ex-commands and the `'packlockfile'` option
documented on Neovim master are **0.13-dev only**. Everything must be driven
from Lua.

There is also no lazy loading of any kind — no `event`, `cmd`, `keys`, `ft`.

### Verified behaviour of `vim.pack`

Established by isolated probe under `NVIM_APPNAME`, not assumed:

1. `add()` blocks until every plugin in the call is installed; installation is
   parallel **within** a call.
2. With `{ load = true }`, `plugin/` files are sourced **during** the `add()`
   call — a command defined by a plugin's `plugin/` file returns
   `vim.fn.exists(':Cmd') == 2` on the line immediately after `add()`.
3. `require()` of a freshly installed plugin works synchronously on the line
   after `add()` returns, still inside `init.lua`.
4. Plugins install to `<data>/site/pack/core/opt/<name>`.

(1) is why the design uses exactly one `add()` call. (2) is why `load = true` is
passed explicitly rather than relying on the context-dependent default — it
reproduces lazy.nvim's ordering (plugin/ sourced, then config runs).

---

## 2. Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Lazy loading | Eager; measure; tune only what hurts | `vim.pack` has none. Hand-rolling 13 triggers up front optimizes before measuring. |
| Cutover | In-place rewrite of `~/.config/nvim` | User preference. Rollback is `cp -r` from the dotfiles repo, plus per-step git history from `5b57b3c`. |
| Update UX | `:PackUpdate` / `:PackDel` / `:PackStatus` + keymap; lualine indicator dropped | An indicator needs a background fetch of 48 repos per launch. That cost is why lazy's checker was opt-in. |
| Structure | Declarative modules + composition root | Gets one `add()` (performance) *and* per-plugin files (readability) with no tradeoff. |
| Config-less deps | Grouped under the plugin they serve | See placement rule below. |
| Ordering | Explicit list in one file | Replaces 18 nested `dependencies` lists that `vim.pack` will not resolve. |
| Doc verification | Mandatory, from disk, per plugin | See §6. |

### Placement rule

> A config-less plugin serving **exactly one** plugin goes in that plugin's
> `deps`. One that is **shared infrastructure** (`plenary`, `nvim-web-devicons`)
> or **standalone** (`vim-tmux-navigator`) gets its own file — it has no single
> owner. Anything with config of its own always gets a file.

Collapses **47 repos into 28 module files**. (47, not 48: lsp-zero is deleted
outright, see §5.)

---

## 3. Architecture

### Module contract

```lua
---@class PluginSpec
---@field src      string    -- "owner/repo"; github.com assumed
---@field deps?    (string | { src: string, version?: string, build?: string[] })[]
---@field version? string|table  -- branch, tag, or vim.version.range()
---@field name?    string    -- override installed directory name
---@field build?   string[]  -- argv; runs on install and update
---@field setup?   fun()     -- what lazy called `config`
```

Modules are **inert tables**. Nothing executes at `require` time. This is what
lets the composition root require all modules up front and still control
execution order independently.

### Layers

```
init.lua
├─ config.core                      unchanged (options, keymaps)
├─ config.pack                      composition root — ONLY file touching vim.pack
│   ├─ config.pack.registry         ordered module list = the dependency graph
│   ├─ config.pack.build            PackChanged autocmd, registered BEFORE add()
│   └─ config.plugins.*             28 inert declarations
├─ config.pack.commands             :PackUpdate / :PackDel / :PackStatus
└─ config.plugins.custom.clean_architecture_generator    unchanged
```

Dependency direction is one-way: `plugins/*` know nothing about `pack/*`.
A plugin module is a value; the root is the only thing that interprets it.

### Composition root

```lua
-- lua/config/pack/init.lua
local registry = require("config.pack.registry")
local GITHUB = "https://github.com/"

local specs, mods = {}, {}
for _, name in ipairs(registry) do
  local m = require("config.plugins." .. name)
  mods[#mods + 1] = m
  for _, d in ipairs(m.deps or {}) do
    local d_spec = type(d) == "string" and { src = d } or d
    specs[#specs + 1] = {
      src = GITHUB .. d_spec.src, version = d_spec.version, name = d_spec.name,
    }
  end
  specs[#specs + 1] = { src = GITHUB .. m.src, version = m.version, name = m.name }
end

require("config.pack.build").register(mods)          -- MUST precede add()
vim.pack.add(specs, { load = true, confirm = false })

for _, m in ipairs(mods) do
  if m.setup then m.setup() end
end
```

Deps precede their owner in the spec list so `packadd` order matches
lazy's dependency semantics. `add()` deduplicates — *"Adding plugin second and
more times during single session does nothing"* — so `plenary` appearing under
six owners is harmless.

### Build hooks

Registered as a `PackChanged` autocmd **before** the first `add()`, or
install-time hooks never fire:

```lua
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local kind = ev.data.kind
    if kind ~= "install" and kind ~= "update" then return end
    local cmd = build_by_name[ev.data.spec.name]
    if cmd then vim.system(cmd, { cwd = ev.data.path }):wait() end
  end,
})
```

---

## 4. Plugin mapping

### Pins

| Plugin | lazy.nvim | vim.pack |
|---|---|---|
| `arctic.nvim` | `branch = "main"` | `version = "main"` |
| `nvim-treesitter` | `branch = "main"` | `version = "main"` |
| `nvim-treesitter-textobjects` | `branch = "main"` | `version = "main"` |
| `harpoon` | `branch = "harpoon2"` | `version = "harpoon2"` |
| `LuaSnip` | `version = "v2.*"` | `vim.version.range("2")` |

`priority = 1000` on the colorscheme has no equivalent and needs none — the
registry places `lush` then `arctic` early, which is what priority was
simulating.

### Build hooks

| Plugin | lazy.nvim | vim.pack |
|---|---|---|
| `LuaSnip` | `build = "make install_jsregexp"` | `{ "make", "install_jsregexp" }` |
| `telescope-fzf-native.nvim` | `build = "make"` | `{ "make" }` |
| `nvim-treesitter` | `build = ":TSUpdate"` | **dropped** |

`:TSUpdate` is dropped because the existing config already installs parsers
itself through the main-branch API (`nvim-treesitter.config.get_installed()`
then `nvim-treesitter.install.install()`), making the build hook redundant.

### Load order

Registry sequence. Entries are **module files**; their `deps` ride along with
their owner and are not listed separately.

| # | Modules | Ordering constraint |
|---|---|---|
| 1 | `plenary`, `devicons` | shared infrastructure, no owner |
| 2 | `colorscheme` | needs its `lush` dep; early placement replaces `priority = 1000` |
| 3 | `treesitter`, `ts_autotag`, `treesitter_textobjects` | textobjects queries need the parser API loaded first |
| 4 | `mason`, `lsp_file_operations`, `lspconfig` | mason's deps register servers; they must precede lspconfig configuring them |
| 5 | `flutter_bloc`, `flutter_tools` | need `none-ls` and lspconfig in place |
| 6 | `cmp`, `autopairs` | autopairs hooks cmp's confirm event, so it must follow cmp |
| 7 | `codeium`, `conform`, `lint` | none |
| 8 | `todo_comments`, `trouble`, `telescope`, `harpoon` | telescope **and** trouble both declare todo-comments; telescope's own config requires `trouble.sources.telescope`, so trouble must also precede telescope |
| 9 | `gitsigns`, `comment`, `bufferline`, `lualine`, `fidget`, `dressing`, `tmux_navigator` | none |
| 10 | `dap` | none |

### Deletions

- `lua/config/lazy.lua` — bootstrap
- `lazy-lock.json` — superseded by the vim.pack lockfile
- `lua/config/plugins/general.lua` — pure sources, no config; repos redistribute
- `lua/config/plugins/lsp/lsp-zero.lua` — plugin removed entirely, see §5
- `lua/config/plugins/lualine.lua:6,83,84` — the `require("lazy.status")` segment
- `~/.local/share/nvim/lazy/` — **only after** the verification gate passes

---

## 5. Defect fixes

Included because each is backed by a quotable source, not by preference.

### lsp-zero removed

`~/.local/share/nvim/lazy/lsp-zero.nvim/README.md`, first section:

> ## Project status
>
> Dead.
>
> It took about 3 years but finally Neovim has solved all the issues that led to
> the creation of this plugin. Neovim v0.11 can provide everything you need
> without installing extra plugins.

Two call sites in `lsp-config.lua` move to natives:

```lua
lsp_zero.extend_lspconfig({ capabilities = ..., lsp_attach = ... })
  -> vim.lsp.config("*", { capabilities = ... })
  -> vim.api.nvim_create_autocmd("LspAttach", { callback = lsp_attach })

lsp_zero.ui({ float_border = ..., sign_text = {...} })
  -> vim.diagnostic.config({ signs = { text = {...} } })
  -> vim.o.winborder / vim.lsp.buf.hover({ border = ... })
```

### Duplicate `vim.lsp.enable("ts_ls")` removed

`mason-lspconfig` v2's `automatic_enable` already calls `vim.lsp.enable()` for
every installed server. `lsp-config.lua:79-85` adds a `FileType` autocmd doing
it a second time. The autocmd goes; the `vim.lsp.config("ts_ls", {...})` block
stays, since that supplies the settings.

### Duplicate `capabilities` removed

Set once via `lsp_zero.extend_lspconfig` and again inline in the `ts_ls` block.
Collapses to a single `vim.lsp.config("*", { capabilities = ... })`.

### `vim.diagnostic.config` consolidated

Found during implementation. It was called twice: once in nvim-cmp's config
(`update_in_insert`, `virtual_text`, `signs = true`, `underline`) and once via
`lsp_zero.ui` (`sign_text`). `vim.diagnostic.config` replaces the keys it is
given, so whichever ran last silently discarded the other's — with cmp
configured after lspconfig, `signs = true` was overwriting the sign glyphs.
Merged into a single call in `lspconfig.lua`.

### mason retargeted to `mason-org`

Installed remote is `williamboman/mason.nvim`; the README's own CI badges point
at `mason-org/mason.nvim`. Same for `mason-lspconfig`. The old paths still
redirect, but the canonical source moved. Installed versions confirmed current:
mason `v2.2.1`, mason-lspconfig `v2.1.0`, nvim-lspconfig `v2.8.0`.

---

## 6. Doc verification procedure

**Every plugin's configuration is verified against that plugin's own
documentation at the exact revision installed, before its `setup()` is written.**
Not from memory, not from the web — from disk. After `add()`, each plugin's
`README.md`, `doc/*.txt` and `lua/` sit in
`~/.local/share/nvim/site/pack/core/opt/<name>/` at precisely the revision being
run, which is a stricter source than any web page that may describe a different
version.

This forces two phases:

**Phase 1 — install only.** `vim.pack.add()` all 48 with pins and build hooks,
no `setup()` anywhere. Nothing is configured, so nothing can be misconfigured;
everything lands on disk at final revisions.

**Phase 2 — configure one plugin at a time.** Per plugin: read `doc/` and README
at that revision → diff against the current lazy config → write the module →
verify → commit → next.

Consequence worth stating plainly: **`lazy-lock.json` pins exact commits and
`vim.pack` installs fresh at branch tips, so all 48 plugins move forward.** The
docs forbid hand-editing the vim.pack lockfile, so the pins cannot be carried
across. Phase 1 exists precisely so that this drift is absorbed and observed
before any config is written against it.

The LSP stack is gated on three sources that currently disagree with what
`lsp-config.lua` does: `nvim-lspconfig/doc/lspconfig.txt`, the `mason-lspconfig`
v2 README, and `:h lsp-config` / `:h vim.lsp.enable` from the local 0.12.5
runtime.

---

## 7. Update commands

```lua
:PackUpdate           -- vim.pack.update()
:PackUpdate!          -- force, skip confirmation buffer
:PackUpdate <name>    -- single plugin
:PackDel <name>       -- vim.pack.del()
:PackStatus           -- vim.pack.update(nil, { offline = true })
```

Defined only when the native command is absent, so they do not collide when
0.13 ships `:packupdate`:

```lua
if vim.fn.exists(":packupdate") == 0 then ... end
```

---

## 8. Verification gate

No step counts as done on "it opened".

1. `nvim --headless -c 'q'` exits clean, zero errors.
2. Startup measured 3× via `--startuptime` against the **110 ms** baseline.
3. `:checkhealth vim.pack` clean; `lazy` absent from `:checkhealth`.
4. Functional smoke list: colorscheme applied · LSP attaches on `.ts` and
   `.dart` · cmp completes · treesitter highlights · conform formats · telescope
   opens · harpoon marks · trouble opens · DAP loads · codeium suggests ·
   gitsigns renders · bufferline and lualine render.
5. Only then: remove `~/.local/share/nvim/lazy/`, sync to `dotfile_hyperland`
   **excluding `.git`**, commit, push.

Rollback at any point:

```sh
rm -rf ~/.config/nvim && cp -r ~/Downloads/dotfile_hyperland/nvim ~/.config/nvim
```

Finer-grained rollback via the config's own git history from `5b57b3c`.

---

## 9. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| All 48 plugins jump to branch tips | High | Phase 1 isolates install from config. First hypothesis for any breakage is "that plugin moved", not "vim.pack is broken". |
| Eager loading regresses startup | Medium | Measured against the 110 ms baseline at the gate. Tuning is a follow-up, not a blocker; `load = false` plus autocmds is the escape hatch. |
| `vim.version.range("2")` mis-resolves LuaSnip | Low | Depends on LuaSnip tags being strict semver. Fallback: `version = nil`. Verify at phase 1. |
| LSP rewrite regresses on Dart or TS | Medium | Both filetypes are explicit in the smoke list. `flutter-tools` gets its `dartls` handler checked against its own docs. |
| `vim.pack` is experimental | Accepted | Its docs say so. Rollback path is verified and cheap. |
| Syncing the config's `.git` into the dotfiles repo | Low | Sync excludes `.git`. |

---

## 10. Decomposition

Spec 1 stops at a working, verified vim.pack config. The user approved a wider
goal ("best IDE config as possible", explicitly options 2 **and** 3), split into
later cycles:

- **Spec 2 — 0.12 native modernization.** Inlay hints,
  `vim.lsp.document_color`, treesitter folds, `virtual_lines` diagnostics,
  native completion evaluated against nvim-cmp; remove plugins the natives
  replace.
- **Spec 3 — IDE capability audit.** Currently absent: file explorer (telescope
  + harpoon only), session management, test runner, git UI beyond gitsigns, DAP
  UI beyond raw nvim-dap, project-wide search-and-replace. Proposed for
  approval, never installed unilaterally.

The split exists for bisectability. If the structural rewrite, the native-API
swap, new plugins, **and** 48 plugins' worth of upstream drift all land at once,
a failure cannot be attributed to any one of them.


---

## 11. Results

Recorded after implementation. Every claim below was measured, not assumed.

### Verification gate

| Check | Result |
|---|---|
| 47 spec entries -> 47 unique repos, no duplicates | pass |
| All 47 installed to `site/pack/core/opt` | pass |
| Build hook: `telescope-fzf-native` | `build/libfzf.so` produced |
| Build hook: `LuaSnip` | `deps/jsregexp/jsregexp.so` produced |
| Pin: `LuaSnip` `vim.version.range("2")` | resolved to `v2.5.0` — the risk in §9 did not materialise |
| Pin: arctic / nvim-treesitter | `origin/main` |
| Pin: harpoon | `origin/harpoon2` |
| mason installed from `mason-org` | pass |
| lsp-zero absent from disk | pass |
| 24 requested treesitter parsers built | pass (27 present) |
| Functional smoke suite, 32 checks | 32 pass, 0 fail |
| `ts_ls` attaches to a real `.ts` buffer | pass |
| Interactive quit through a pty | clean, exit 0 |

### Startup

| Config | Runs | Mean |
|---|---|---|
| lazy.nvim (baseline commit `5b57b3c`) | 192 / 193 / 210 ms | **198 ms** |
| vim.pack, eager | 280 / 272 / 274 ms | **275 ms** |

+77 ms (~39%) for loading all 47 plugins eagerly. Both measured identically
through a pty. Tuning is deferred until the maintainer decides the cost is
worth paying, per the decision in §2.

### Defects found during implementation

Three, none of which were visible from the lazy.nvim config alone:

1. **Treesitter highlighting was never running.** The config asserted that
   Neovim 0.12 activates highlighting automatically for installed parsers.
   nvim-treesitter's main-branch README states the opposite in bold: its
   features are *"not automatically enabled"*. Confirmed against the
   pre-migration config too — `.ts`, `.lua` and `.dart` all reported
   `vim.treesitter.highlighter.active[buf] == nil`. **Pre-existing, not
   migration fallout.** Fixed with a FileType autocmd calling
   `vim.treesitter.start()`; all three filetypes now report highlighting ON.

2. **flutter-tools `lsp.color` is deprecated.** The freshly installed version
   warns on every startup that plugin-managed document colours go away once it
   requires 0.12+, and names `vim.lsp.document_color.enable()` as the
   replacement. Enabled from the shared `LspAttach` handler for any client
   advertising `textDocument/documentColor`, so cssls and tailwindcss benefit
   too. Native `document_color` takes one `style` where the old block combined
   background with virtual text; `background` was kept.

3. **`vim.diagnostic.config` was called twice** (see §5), which the migration
   surfaced by removing the shim that hid it.

### Known non-defect

`nvim --headless -c q` does not exit: codeium.vim starts its `language_server`
child during startup and headless Nvim waits on it. **Interactive Nvim quits
cleanly** (verified through a pty, exit 0), and the baseline spawns the same
server. The baseline's headless run only appeared clean because it exited at
0.25 s, before the server registered — a race, not a behavioural difference.
Headless verification therefore runs under a pty via `script`.
