return {
  "ThePrimeagen/harpoon",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon.setup({
      menu = {
        width = vim.api.nvim_win_get_width(0) - 90,
      },
    })
  end,
}
