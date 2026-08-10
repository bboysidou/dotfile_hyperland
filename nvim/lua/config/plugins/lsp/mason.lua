return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- import mason-null-ls
    local mason_tool_installer = require("mason-tool-installer")
    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls",
        -- "clangd",
        "eslint",
        "rust_analyzer",
        "pyright",
        -- "cssls",
        "tailwindcss",
        -- "svelte",
        "cssmodules_ls",
        "docker_compose_language_service",
        "dockerls",
        -- "graphql",
        "html",
        "sqlls",
        "jsonls",
        "lua_ls",
        "emmet_ls",
        "gopls",
        -- "intelephense",
        -- "jdtls",
      },
      -- installed servers are enabled via vim.lsp.enable() automatically.
      -- exclude tools that mason installs as formatters/linters but that
      -- nvim-lspconfig also ships a (non-desirable) LSP config for.
      automatic_enable = {
        exclude = { "stylua" },
      },
    })
    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "prettierd", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "clang-format", -- c formatter
        "pylint", -- python linter
        "eslint_d", -- js linter
        "sql-formatter", -- sql linter
        "sqlfluff", -- sql linter
      },
      auto_update = true,
      run_on_start = true,
    })
  end,
}
