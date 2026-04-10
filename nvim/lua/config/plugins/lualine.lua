return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")
    local c = require("config.colors")

    local my_lualine_theme = {
      normal = {
        a = { bg = c.blue, fg = c.bg, gui = "bold" },
        b = { bg = c.yellow, fg = c.bg },
        c = { bg = c.bg, fg = c.fg_bright },
        y = { bg = c.bg_selection, fg = c.fg_bright },
      },
      insert = {
        a = { bg = c.green, fg = c.bg, gui = "bold" },
        b = { bg = c.yellow, fg = c.bg },
        c = { bg = c.bg, fg = c.fg_bright },
        y = { bg = c.bg_selection, fg = c.fg_bright },
      },
      visual = {
        a = { bg = c.magenta, fg = c.bg, gui = "bold" },
        b = { bg = c.yellow, fg = c.bg },
        c = { bg = c.bg, fg = c.fg_bright },
        y = { bg = c.bg_selection, fg = c.fg_bright },
      },
      command = {
        a = { bg = c.yellow, fg = c.bg, gui = "bold" },
        b = { bg = c.bg_selection, fg = c.fg },
        c = { bg = c.bg, fg = c.fg_bright },
        y = { bg = c.bg_selection, fg = c.fg_bright },
      },
      replace = {
        a = { bg = c.red, fg = c.bg, gui = "bold" },
        b = { bg = c.yellow, fg = c.bg },
        c = { bg = c.bg, fg = c.fg_bright },
        y = { bg = c.bg_selection, fg = c.fg_bright },
      },
      inactive = {
        a = { bg = c.bg_light, fg = c.fg_muted, gui = "bold" },
        b = { bg = c.bg_light, fg = c.fg_muted },
        c = { bg = c.bg_light, fg = c.fg_muted },
        y = { bg = c.bg_light, fg = c.fg_muted },
      },
    }

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = my_lualine_theme,
        section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
        component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = function()
              local signs = vim.b.gitsigns_status_dict
              if not signs then return end
              if (signs.added or 0) > 0 or (signs.changed or 0) > 0 or (signs.removed or 0) > 0 then
                return { bg = c.yellow, fg = c.bg, gui = "bold" }
              end
              return { bg = c.green, fg = c.bg, gui = "bold" }
            end,
          },
          {
            "diff",
            symbols = { added = "+", modified = "!", removed = "-" },
            diff_color = {
              added = { fg = c.green },
              modified = { fg = c.yellow },
              removed = { fg = c.red },
            },
          },
        },
        lualine_c = { { "filename", path = 3, shorting_target = 30 } },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = c.orange },
          },
          { "fileformat" },
          { "filetype" },
        },
        lualine_y = { "diagnostics" },
        lualine_z = { "location" },
      },
    })
  end,
}
