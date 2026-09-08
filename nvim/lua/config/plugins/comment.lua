return {
  src = "numToStr/Comment.nvim",
  deps = { "JoosepAlviste/nvim-ts-context-commentstring" },
  setup = function()
    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    require("Comment").setup({
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })
  end,
}
