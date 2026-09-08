return {
  src = "MeanderingProgrammer/render-markdown.nvim",
  setup = function()
    require("render-markdown").setup({
      completions = { lsp = { enabled = true } },
    })

    vim.keymap.set("n", "<leader>vm", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown rendering" })
  end,
}
