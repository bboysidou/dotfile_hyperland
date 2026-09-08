-- lazy's `keys` triggered lazy-loading; with vim.pack the plugin is always
-- loaded, so these are plain keymaps.
local KEYS = {
  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)" },
  { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)" },
  { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", "Symbols (Trouble)" },
  { "<leader>xl", "<cmd>Trouble lsp toggle<cr>", "LSP Definitions / references / ... (Trouble)" },
  { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)" },
  { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)" },
}

return {
  src = "folke/trouble.nvim",
  setup = function()
    require("trouble").setup({ position = "right" })

    for _, key in ipairs(KEYS) do
      vim.keymap.set("n", key[1], key[2], { desc = key[3] })
    end
  end,
}
