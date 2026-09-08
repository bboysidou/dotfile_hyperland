-- main branch. The README is explicit that features are "not automatically
-- enabled": Neovim provides treesitter highlighting but nothing starts it, so
-- a FileType autocmd calls vim.treesitter.start() for any filetype whose
-- parser is installed. The previous config assumed 0.12 did this by itself and
-- consequently ran with no treesitter highlighting at all.
--
-- Parser installation happens here rather than via a build hook.
local PARSERS = {
  "json",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "html",
  "toml",
  "css",
  "markdown",
  "markdown_inline",
  "svelte",
  "graphql",
  "bash",
  "lua",
  "vim",
  "rust",
  "dart",
  "dockerfile",
  "gitignore",
  "sql",
  "c",
  "java",
  "go",
  "python",
}

return {
  src = "nvim-treesitter/nvim-treesitter",
  version = "main",
  setup = function()
    local installed = require("nvim-treesitter.config").get_installed()
    local missing = vim.tbl_filter(function(parser)
      return not vim.list_contains(installed, parser)
    end, PARSERS)

    if #missing > 0 then
      require("nvim-treesitter.install").install(missing)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end
        if not pcall(vim.treesitter.language.add, lang) then
          return
        end
        if not pcall(vim.treesitter.start, ev.buf, lang) then
          return
        end

        -- Folds are opt-in on the main branch exactly like highlighting.
        -- foldlevelstart = 99 in options.lua keeps files opened unfolded.
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
      end,
    })
  end,
}
