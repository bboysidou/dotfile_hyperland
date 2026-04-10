return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    branch = "main",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require("nvim-ts-autotag").setup()

      -- Ensure parsers are installed
      local parsers = {
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

      -- Auto-install missing parsers
      local installed = require("nvim-treesitter.config").get_installed()
      local to_install = vim.tbl_filter(function(p)
        return not vim.list_contains(installed, p)
      end, parsers)

      if #to_install > 0 then
        require("nvim-treesitter.install").install(to_install)
      end

      -- Highlighting and indent are built-in to Neovim 0.12+
      -- They activate automatically for installed parsers
    end,
  },
}
