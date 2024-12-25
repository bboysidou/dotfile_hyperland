return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  branch = "main",
  -- version = "*",
  config = function()
    local bufferline = require("bufferline")
    bufferline.setup({
      -- highlights = {
      --   fill = {
      --     fg = "#ff0000",
      --     bg = "#010101",
      --   },
      --   background = {
      --     fg = "#aaaaaa",
      --     bg = "#111111",
      --   },
      --   buffer_selected = {
      --     fg = "#ffffff",
      --     bg = "#000000",
      --     bold = true,
      --     italic = true,
      --   },
      --   indicator_selected = {
      --     fg = "#000000",
      --     bg = "#ffffff",
      --   },
      --   separator = {
      --     fg = "#000000",
      --     bg = "#000000",
      --   },
      -- },
      options = {
        mode = "buffers", -- set to "tabs" to only show tabpages instead
        style_preset = bufferline.style_preset.default, -- or bufferline.style_preset.minimal,
        themable = true, -- allows highlight groups to be overriden i.e. sets highlights as default
        numbers = "none",
        close_command = "bdelete! %d", -- can be a string | function, | false see "Mouse actions"
        right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
        left_mouse_command = "buffer %d", -- can be a string | function, | false see "Mouse actions"
        middle_mouse_command = nil, -- can be a string | function, | false see "Mouse actions"
        indicator = {
          -- icon = "▎", -- this should be omitted if indicator style is not 'icon'
          style = "icon", --'icon' | 'underline' | 'none',
        },
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = " ",
        left_trunc_marker = " ",
        right_trunc_marker = " ",
        --- name_formatter can be used to change the buffer's label in the bufferline.
        --- Please note some names can/will break the
        --- bufferline so use this at your discretion knowing that it has
        --- some limitations that will *NOT* be fixed.
        max_name_length = 30,
        max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
        tab_size = 21,
        truncate_names = true, -- whether or not tab names should be truncated
        diagnostics = "nvim_lsp", --false | "nvim_lsp" | "coc",
        diagnostics_update_in_insert = false, -- only applies to coc
        diagnostics_update_on_event = true, -- use nvim's diagnostic handler
        -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "",
            highlight = "Directory",
            separator = true,
          },
        },
        color_icons = true, -- whether or not to add the filetype icon highlights
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        duplicates_across_groups = true, -- whether to consider duplicate paths in different groups as duplicates
        move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { '|', '|' }
        separator_style = "thick", --"slant" | "slope" | "thick" | "thin" | { "any", "any" },
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
      },
    })
  end,
}
