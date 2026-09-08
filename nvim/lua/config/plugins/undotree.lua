return {
  src = "mbbill/undotree",
  setup = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SetFocusWhenToggle = 1

    vim.keymap.set("n", "<leader>vu", "<cmd>UndotreeToggle<cr>", { desc = "Toggle undo tree" })
  end,
}
