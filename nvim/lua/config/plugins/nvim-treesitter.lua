return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      -- import nvim-treesitter plugin
      -- require("nvim-ts-autotag").setup()
      local treesitter = require("nvim-treesitter.configs")
      -- local ts_context_commentstring = require("ts_context_commentstring").setup({})

      -- configure treesitter
      treesitter.setup({
        modules = {},
        -- enable syntax highlighting
        highlight = {
          enable = true,
        },
        -- enable indentation
        indent = { enable = true },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = { enable = true },
        -- ensure these language parsers are installed
        ensure_installed = {
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
          -- "php",
          "c",
          "java",
        },
        -- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
        ts_context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        -- context_commentstring = {
        --   enable = true,
        --   enable_autocmd = false,
        -- },
        -- auto install above language parsers
        auto_install = true,
        sync_install = false,
        ignore_install = {},
      })
    end,
  },
}
