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
        -- INFO is its own keyword above, so it must not also be an alt of NOTE
        -- (the alt would win and render INFO with NOTE's colour).
        NOTE = { icon = " ", color = "hint" },
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
