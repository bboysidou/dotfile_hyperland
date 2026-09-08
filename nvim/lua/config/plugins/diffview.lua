-- gitsigns covers hunks inside the current buffer; this covers revision ranges,
-- file history and 3-way conflict resolution.
return {
  src = "sindrets/diffview.nvim",
  setup = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
    })

    vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview: open" })
    vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview: file history" })
    vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview: branch history" })
    vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Diffview: close" })
  end,
}
