-- Retargeted from williamboman/* to mason-org/*: the project moved orgs and
-- the old paths are redirects.
return {
  src = "mason-org/mason.nvim",
  deps = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  setup = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "ts_ls",
        "eslint",
        "rust_analyzer",
        "pyright",
        "tailwindcss",
        "cssmodules_ls",
        "docker_compose_language_service",
        "dockerls",
        "html",
        "sqlls",
        "jsonls",
        "lua_ls",
        "emmet_ls",
        "gopls",
      },
      -- v2 enables installed servers via vim.lsp.enable() on its own; exclude
      -- tools mason installs as formatters that lspconfig also ships an
      -- undesirable server config for.
      automatic_enable = {
        exclude = { "stylua" },
      },
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "prettier",
        "prettierd",
        "stylua",
        "isort",
        "black",
        "clang-format",
        "pylint",
        "eslint_d",
        "sql-formatter",
        "sqlfluff",
      },
      auto_update = true,
      run_on_start = true,
    })
  end,
}
