return {
  "rockyzhang24/arctic.nvim",
  dependencies = { "rktjmp/lush.nvim" },
  name = "arctic",
  branch = "main",
  priority = 1000,
  config = function()
    local c = require("config.colors")

    vim.cmd("colorscheme arctic")

    -- Force Netrw to use full background
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "netrw",
      callback = function()
        vim.cmd("highlight NetrwNormal guibg=" .. c.bg)
        vim.cmd("highlight NetrwCursorLine guibg=" .. c.bg_alt .. " ctermbg=235")
        vim.cmd("setlocal winhighlight=Normal:NetrwNormal,CursorLine:NetrwCursorLine")
      end,
    })

    -- General UI Fixes
    vim.cmd("highlight Normal guibg=" .. c.bg)
    vim.cmd("highlight NormalNC guibg=" .. c.bg)
    vim.cmd("highlight EndOfBuffer guibg=" .. c.bg)
    vim.cmd("highlight SignColumn guibg=" .. c.bg)

    -- Ensure Netrw folders are blue
    vim.cmd("highlight NetrwDir guifg=" .. c.blue .. " guibg=" .. c.bg)

    -- LSP completion menu
    vim.cmd("highlight Pmenu guibg=" .. c.bg .. " guifg=" .. c.fg_bright)
    vim.cmd("highlight PmenuSel guibg=" .. c.bg_light .. " guifg=" .. c.fg_bright)
    vim.cmd("highlight PmenuThumb guibg=" .. c.bg_lighter)
    vim.cmd("highlight PmenuSbar guibg=" .. c.bg_alt)

    -- Bufferline, Telescope, Mason backgrounds
    vim.cmd("highlight TelescopeNormal guibg=" .. c.bg)
    vim.cmd("highlight MasonNormal guibg=" .. c.bg)
    vim.cmd("highlight BufferLineFill guibg=" .. c.bg)

    vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = c.blue })
    vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = c.blue })
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = c.fg })
    vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = c.green })
    vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = c.green })
    vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = c.magenta })
    vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = c.bright_blue })
    vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = c.bright_magenta })
    vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = c.bright_yellow })
  end,
}

-- return {
--   "folke/tokyonight.nvim",
--   priority = 1000,
--   config = function()
--     local bg = "#000000"
--     local bg_dark = "#000000"
--     local bg_highlight = "#011423"
--     -- local bg_search = "#0A64AC"
--     -- local bg_visual = "#275378"
--     local fg = "#CBE0F0"
--     local fg_dark = "#B4D0E9"
--     local fg_gutter = "#627E97"
--     local border = "#547998"
--     --
--     require("tokyonight").setup({
--       style = "night",
--       on_colors = function(colors)
--         colors.bg = bg
--         colors.bg_dark = bg_dark
--         colors.bg_float = bg_dark
--         colors.bg_highlight = bg_highlight
--         colors.bg_popup = bg_dark
--         -- colors.bg_search = bg_search
--         colors.bg_sidebar = bg_dark
--         --     colors.bg_statusline = bg_dark
--         --     colors.bg_visual = bg_visual
--         colors.border = border
--         -- colors.fg = fg
--         colors.fg_dark = fg_dark
--         colors.fg_float = fg
--         colors.fg_gutter = fg_gutter
--         colors.fg_sidebar = fg_dark
--       end,
--     })
--
--     vim.cmd("colorscheme tokyonight-night")
--   end,
-- }
