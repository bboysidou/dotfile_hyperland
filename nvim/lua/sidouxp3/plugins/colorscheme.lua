return {
  "rockyzhang24/arctic.nvim",
  dependencies = { "rktjmp/lush.nvim" },
  name = "arctic",
  branch = "main",
  priority = 1000,
  config = function()
    -- Apply Arctic colorscheme
    vim.cmd("colorscheme arctic")

    -- Force Netrw to use full background
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "netrw",
      callback = function()
        -- Set Netrw background and cursor highlight
        vim.cmd("highlight NetrwNormal guibg=#000000")
        vim.cmd("highlight NetrwCursorLine guibg=#111111 ctermbg=235")

        -- Force Netrw to use CursorLine correctly
        vim.cmd("setlocal winhighlight=Normal:NetrwNormal,CursorLine:NetrwCursorLine")
      end,
    })

    -- General UI Fixes
    vim.cmd("highlight Normal guibg=#000000")
    vim.cmd("highlight NormalNC guibg=#000000")
    vim.cmd("highlight EndOfBuffer guibg=#000000")
    vim.cmd("highlight SignColumn guibg=#000000")

    -- Ensure Netrw folders are blue
    vim.cmd("highlight NetrwDir guifg=#61afef guibg=#000000")

    -- LSP completion menu black
    vim.cmd("highlight Pmenu guibg=#000000 guifg=#ffffff")
    vim.cmd("highlight PmenuSel guibg=#222222 guifg=#ffffff")
    vim.cmd("highlight PmenuThumb guibg=#444444")
    vim.cmd("highlight PmenuSbar guibg=#111111")

    -- Ensure Bufferline, Telescope, and Mason also have black backgrounds
    vim.cmd("highlight TelescopeNormal guibg=#000000")
    vim.cmd("highlight MasonNormal guibg=#000000")
    vim.cmd("highlight BufferLineFill guibg=#000000")

    vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#91B4D5" }) -- soft blue
    vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#91B4D5" })
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#C4C9C6" }) -- light gray
    vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#B4BE82" }) -- soft green
    vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#B4BE82" })
    vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#E5C890" }) -- yellow
    vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#D4879C" }) -- pink
    vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#C6D0F5" }) -- subtle lavender
    vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#F4B8E4" }) -- magenta
    vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#FFC914" }) -- a golden yellow
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
