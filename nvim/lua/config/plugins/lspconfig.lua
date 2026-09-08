-- lsp-zero is gone: its own README states "Project status: Dead." and points at
-- Neovim 0.11+ natives. Its two call sites map as follows.
--
--   lsp_zero.extend_lspconfig{ capabilities, lsp_attach }
--     -> vim.lsp.config("*", { capabilities })  +  an LspAttach autocmd
--   lsp_zero.ui{ float_border, sign_text }
--     -> vim.o.winborder  +  vim.diagnostic.config{ signs.text }
--
-- All vim.diagnostic.config lives here. It used to be split between this file
-- and nvim-cmp's config, where whichever ran last clobbered the other's keys.

-- Neovim 0.12 implements these natively; each is gated on the server actually
-- advertising the capability, so a server without it is simply skipped.
--
-- The three filter tables are NOT interchangeable and each rejects keys it does
-- not declare: document_color takes bufnr + client_id, inlay_hint takes bufnr
-- alone, linked_editing_range takes client_id alone.
local function enable_native_features(client, bufnr)
  if client:supports_method("textDocument/documentColor") then
    vim.lsp.document_color.enable(true, { bufnr = bufnr, client_id = client.id }, { style = "background" })
  end

  if client:supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  -- renames the matching tag/identifier as you type (JSX/HTML pairs, etc.)
  if client:supports_method("textDocument/linkedEditingRange") then
    vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
  end
end

local function on_attach(client, bufnr)
  if client then
    enable_native_features(client, bufnr)
  end

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "gR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
  map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
  map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
  map("n", "gs", vim.lsp.buf.signature_help, "Show LSP signature help")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
  map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
  map("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")

  map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, "Go to previous diagnostic")
  map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, "Go to next diagnostic")

  map("n", "K", vim.lsp.buf.hover, "Show documentation for what is under cursor")

  map({ "n", "x" }, "F", function()
    vim.lsp.buf.format({ async = true })
  end, "Format buffer")

  map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")

  -- replaces the workspace-diagnostics.nvim plugin, which was installed but
  -- never required by any config file
  map("n", "<leader>xw", vim.lsp.buf.workspace_diagnostics, "Workspace diagnostics")

  map("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
  end, "Toggle inlay hints")
end

return {
  src = "neovim/nvim-lspconfig",
  deps = {
    "hrsh7th/cmp-nvim-lsp",
  },
  setup = function()
    vim.diagnostic.config({
      update_in_insert = true,
      underline = true,
      virtual_text = {
        prefix = "●",
        spacing = 2,
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })

    vim.keymap.set("n", "<leader>tl", function()
      vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
    end, { desc = "Toggle diagnostic virtual_lines" })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(ev)
        on_attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf)
      end,
    })

    -- Servers may register capabilities any time AFTER LspAttach. dartls does
    -- exactly this: inlayHint and documentColor both read as unsupported at
    -- attach and only become true later, so gating solely on LspAttach silently
    -- disables both. Documented remedy at :h lsp-attach.
    vim.lsp.handlers["client/registerCapability"] = (function(overridden)
      return function(err, res, ctx)
        local result = overridden(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
          for bufnr in pairs(client.attached_buffers) do
            if vim.api.nvim_buf_is_valid(bufnr) then
              enable_native_features(client, bufnr)
            end
          end
        end
        return result
      end
    end)(vim.lsp.handlers["client/registerCapability"])

    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- mason-lspconfig v2 automatic_enable already calls vim.lsp.enable() for
    -- every installed server, so this only supplies settings.
    vim.lsp.config("ts_ls", {
      cmd = { "typescript-language-server", "--stdio" },
      root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    })
  end,
}
