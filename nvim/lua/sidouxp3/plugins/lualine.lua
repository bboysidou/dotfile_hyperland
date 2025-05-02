return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    local colors = {
      blue = "#569CD6",
      green = "#4EC9B0",
      violet = "#C586C0",
      yellow = "#D7BA7D",
      red = "#FF4A4A",
      white = "#FFFFFF",
      black = "#000000",
      fg = "#C3CCDC",
      bg = "#112638",
      inactive_bg = "#2C3043",

      -- green = "#3EFFDC",
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.black, gui = "bold" },
        b = { bg = colors.yellow, fg = colors.bg },
        c = { bg = colors.black, fg = colors.white },
        y = { bg = colors.bg, fg = colors.white },
      },
      insert = {
        a = { bg = colors.green, fg = colors.black, gui = "bold" },
        b = { bg = colors.yellow, fg = colors.bg },
        c = { bg = colors.black, fg = colors.white },
        y = { bg = colors.bg, fg = colors.white },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.black, gui = "bold" },
        b = { bg = colors.yellow, fg = colors.bg },
        c = { bg = colors.black, fg = colors.white },
        y = { bg = colors.bg, fg = colors.white },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.black, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.black, fg = colors.white },
        y = { bg = colors.bg, fg = colors.white },
      },
      replace = {
        a = { bg = colors.red, fg = colors.black, gui = "bold" },
        b = { bg = colors.yellow, fg = colors.bg },
        c = { bg = colors.black, fg = colors.white },
        y = { bg = colors.bg, fg = colors.white },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.semilightgray },
        c = { bg = colors.inactive_bg, fg = colors.semilightgray },
        y = { bg = colors.inactive_bg, fg = colors.semilightgray },
      },
    }

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        icons_enabled = true,
        theme = my_lualine_theme,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
        },
        lualine_c = { { "filename", path = 3, shorting_target = 30 } },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#FF9E64" },
          },
          -- { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
        lualine_y = { "diagnostics" },
        lualine_z = { "location" },
      },
    })
  end,
}
