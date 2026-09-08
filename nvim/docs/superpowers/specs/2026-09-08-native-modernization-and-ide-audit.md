# 0.12 native modernization + IDE capability audit

**Date:** 2026-09-08
**Status:** implemented and verified
**Scope:** Specs 2 and 3, following `2026-09-08-vim-pack-migration-design.md`.

Kept as one document because both were implemented in the same sitting and Spec
3's plugin choices depend on what Spec 2 made native.

---

## Spec 2 — Neovim 0.12 natives

### Adopted

| Capability | API | Note |
|---|---|---|
| Inlay hints | `vim.lsp.inlay_hint.enable` | on by default, `<leader>th` toggles |
| Document colours | `vim.lsp.document_color.enable` | `style = "background"` |
| Linked editing | `vim.lsp.linked_editing_range.enable` | dartls does not support it; ts_ls/html do |
| Workspace diagnostics | `vim.lsp.buf.workspace_diagnostics` | `<leader>xw`; replaced a plugin |
| Treesitter folds | `vim.treesitter.foldexpr()` | `foldlevelstart = 99` keeps files open |
| Diagnostic virtual lines | `vim.diagnostic.config{virtual_lines}` | `<leader>tl` toggles; virtual_text stays default |

### Removed

`artemave/workspace-diagnostics.nvim` — installed as a dependency of
nvim-lspconfig but **never required by any config file**. The native API covers
it.

### Deliberately not adopted

- **Native completion** (`vim.lsp.completion.enable`). nvim-cmp here is heavily
  configured (lspkind formatting, LuaSnip expansion, four ordered sources,
  bordered windows) and feeds codeium. Swapping it is a project of its own, not
  a modernization pass.
- **`on_type_formatting`**. conform already formats on save; enabling both
  invites two formatters fighting over the same buffer.
- **Treesitter indentation.** nvim-treesitter's README labels it
  *experimental*. `=` and autoindent currently work.

### Two traps, both silent

**1. Capability gating cannot rely on `LspAttach` alone.**

Measured on dartls in a real Flutter project:

```
AT LspAttach  dartls  inlayHint=false documentColor=false linkedEditing=false
LATER (+27s)  dartls  inlayHint=true  documentColor=true  linkedEditing=false
```

The server registers capabilities *dynamically, after* attach. Anything gated on
`client:supports_method()` inside `LspAttach` is therefore skipped forever.

This had already broken Spec 1: swapping flutter-tools' deprecated `lsp.color`
for native `document_color` looked correct and was dead on arrival, silently
costing Dart its colour swatches. Neither a startup error nor a failing check
would have caught it — only inspecting extmarks did.

Fixed with the remedy documented at `:h lsp-attach`: override the
`client/registerCapability` handler and re-run the enable pass across the
client's attached buffers. Verified after the fix: `document_color` 4 extmarks,
inlay hints 10 extmarks on a Dart buffer.

**2. The three `enable()` filters are not interchangeable.**

| API | accepted filter keys |
|---|---|
| `document_color.enable` | `bufnr`, `client_id` |
| `inlay_hint.enable` | `bufnr` only |
| `linked_editing_range.enable` | `client_id` only |

Each rejects keys it does not declare. Building one shared filter table threw on
the second call and aborted the rest of the enable pass.

---

## Spec 3 — IDE capability audit

Candidates were weighted against this workspace's real stack — Express/TS,
PostgreSQL with raw hand-written SQL and no ORM, Flutter, REST-only APIs, and a
testing policy requiring four layers at 100% coverage — rather than a generic
plugin list. Every addition was approved before installation.

### Added

| Plugin | Gap it closes |
|---|---|
| `neotest` + `neotest-dart` + `neotest-vitest` | Tests are the definition of done, yet nothing could run one from the editor. Debugging a failure reuses the existing nvim-dap setup. |
| `vim-dadbod` + `-ui` + `-completion` | Schema browsing and queries for hand-written SQL; previously a context switch to psql. |
| `diffview.nvim` | Revision ranges, file history, 3-way conflict resolution. gitsigns only covered hunks in the current buffer. |
| `persistence.nvim` | Per-directory session restore. |
| `render-markdown.nvim` | In-buffer rendering for the many in-repo `.md` documents. |
| `undotree` | Undo history as a navigable tree. |

`bun test` has no first-party neotest adapter, so backend suites still run from
a terminal. Flutter and Vitest are covered.

### Declined

which-key, nvim-surround, grug-far, indent-blankline, vim-maximizer. Because
vim-maximizer was declined, the `<leader>sm` binding pointing at its
never-installed `:MaximizerToggle` was **removed** rather than left dead — it had
never worked, predating this migration.

Also not proposed: a file-explorer plugin. `<leader>e` runs a custom
`toggle_netrw()` and the colourscheme carries netrw-specific highlight fixes, so
netrw is a deliberate choice, not a gap.

### Keymaps added

`<leader>T*` tests · `<leader>g*` git · `<leader>v*` tools
(`vd` database, `vu` undotree, `vs`/`vl`/`vq` sessions, `vm` markdown)

Prefixes were chosen from genuinely unused letters. The existing map is crowded:
`<leader>h` is both `nohl` and every gitsigns hunk binding plus the harpoon
menu, and `<leader>p` spans paste, harpoon-prev, textobject swaps and
`:PackStatus`. Those collisions predate this work and cause timeout delays
rather than failures; which-key was the proposed remedy and was declined.

---

## Results

| Check | Result |
|---|---|
| Modules / repos | 34 modules → 57 unique repos, no duplicates |
| Spec 3 verification | 22/22 pass |
| Spec 1 regression suite | 32/32 pass |
| Inlay hints on Dart | enabled, 10 extmarks |
| Document colours on Dart | enabled, 4 extmarks |
| Treesitter folds | `foldmethod=expr`, `foldexpr` set, folds present |

### Startup

| Stage | Mean |
|---|---|
| lazy.nvim baseline | 198 ms |
| vim.pack, Spec 1 | 275 ms |
| vim.pack, Specs 2+3 (57 plugins) | **305 ms** (325 / 300 / 292) |

Everything loads eagerly by decision. If this becomes annoying, the escape hatch
is `load = false` on selected specs plus autocmd triggers — the composition root
already supports it per-module.

### Removing a plugin requires `vim.pack.del()`

Deleting a spec from the config is **not** enough. The lockfile keeps tracking
the plugin and reinstalls it at the next startup, which is exactly what happened
to `workspace-diagnostics.nvim` after Spec 2 dropped it: the directory was
removed, then silently restored. `vim.pack.del()` clears both disk and lockfile.
