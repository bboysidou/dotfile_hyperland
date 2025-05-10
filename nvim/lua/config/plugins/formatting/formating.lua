return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        sql = {
          -- "sqlfluff",
          "sql-formatter",
        },
      },
      formatters = {
        -- ["sqlfluff"] = {
        --   command = "sqlfluff",
        --   args = { "fix", "--dialect", "postgres" }, -- Change 'postgres' to your preferred SQL dialect
        --   stdin = false, -- sqlfluff does not support stdin formatting
        -- },
        ["sql-formatter"] = {
          command = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/sql-formatter"),
          -- args = { "--config", vim.fn.expand("~/.config/sql-formatter.json") }, -- Optional config
          stdin = true,
        },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
