-- LSP keymaps for dartls come from the shared LspAttach autocmd in
-- lspconfig.lua, which fires for every client. flutter-tools no longer accepts
-- an on_attach option.
return {
  src = "akinsho/flutter-tools.nvim",
  setup = function()
    require("flutter-tools").setup({
      decorations = {
        statusline = {
          app_version = true,
          device = false,
          project_config = false,
        },
      },
      widget_guides = {
        enabled = true,
      },
      closing_tags = {
        highlight = "ErrorMsg",
        prefix = ">",
        enabled = true,
      },
      dev_log = {
        enabled = true,
        notify_errors = false,
        open_cmd = "tabedit",
      },
      lsp = {
        -- lsp.color removed: flutter-tools deprecates plugin-managed document
        -- colours on 0.12+ in favour of vim.lsp.document_color, which
        -- lspconfig.lua now enables for every client advertising support.
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          analysisExcludedFolders = { "<path-to-flutter-sdk-packages>" },
          renameFilesWithClasses = "prompt",
          enableSnippets = true,
          updateImportsOnRename = true,
        },
        handlers = {
          ["window/showMessage"] = function(err, result, ctx, config)
            if result and result.message and result.message:match("didChange") then
              return
            end
            vim.lsp.handlers["window/showMessage"](err, result, ctx, config)
          end,
        },
      },
    })
  end,
}
