return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local c = require("config.colors")
    require("todo-comments").setup({
      keywords = {
        TODO = { icon = " ", color = "info" },
        INFO = { icon = " ", color = "info" },
        FIX = { icon = " ", color = "error" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "hint" },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      },
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*:]],
        keyword = "fg",
      },
      colors = {
        error = { c.red },
        warning = { c.warning },
        info = { c.blue },
        hint = { c.green },
        default = { c.magenta },
      },
    })
  end,
}
