return {
  "iabdelkareem/csharp.nvim",
  dependencies = {
    "williamboman/mason.nvim", -- Required, automatically installs omnisharp
    "mfussenegger/nvim-dap",
    "Tastyep/structlog.nvim", -- Optional, but highly recommended for debugging
  },
  event = "BufEnter",
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local mycapabilities = cmp_nvim_lsp.default_capabilities()
    local keymap = vim.keymap -- for conciseness
    local opts = { noremap = true, silent = true }
    local myon_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end
    require("mason").setup() -- Mason setup must run before csharp
    require("csharp").setup(
      -- These are the default values
      {
        lsp = {
          -- When set to false, csharp.nvim won't launch omnisharp automatically.
          enable = true,
          -- When set, csharp.nvim won't install omnisharp automatically. Instead, the omnisharp instance in the cmd_path will be used.
          -- cmd_path = nil,
          -- The default timeout when communicating with omnisharp
          default_timeout = 1000,
          -- Settings that'll be passed to the omnisharp server
          enable_editor_config_support = true,
          organize_imports = true,
          load_projects_on_demand = false,
          enable_analyzers_support = true,
          enable_import_completion = true,
          include_prerelease_sdks = true,
          analyze_open_documents_only = false,
          enable_package_auto_restore = true,
          -- Launches omnisharp in debug mode
          debug = false,
          -- The capabilities to pass to the omnisharp server
          capabilities = mycapabilities,
          -- on_attach function that'll be called when the LSP is attached to a buffer
          on_attach = myon_attach,
        },
        logging = {
          -- The minimum log level.
          level = "INFO",
        },
        dap = {
          -- When set, csharp.nvim won't launch install and debugger automatically. Instead, it'll use the debug adapter specified.
          --- @type string?
          adapter_name = nil,
        },
      }
    )
  end,
}
