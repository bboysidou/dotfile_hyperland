return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    require("todo-comments").setup({
      keywords = {
        TODO = { icon = " ", color = "info" },
        INFO = { icon = " ", color = "info" },
        FIX = { icon = " ", color = "error" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "hint" },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      },
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*:]], -- default pattern
        keyword = "fg", -- 'bg', 'wide', 'fg'
      },
      colors = {
        error = { "#e78284" },
        warning = { "#ffc914" },
        info = { "#007acc" },
        hint = { "#a6d189" },
        default = { "#da70d6" },
      },
    }),
  },
}
