return {
  src = "rockyzhang24/arctic.nvim",
  name = "arctic",
  version = "main",
  deps = { "rktjmp/lush.nvim" },
  setup = function()
    local c = require("config.colors")

    vim.cmd("colorscheme arctic")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "netrw",
      callback = function()
        vim.cmd("highlight NetrwNormal guibg=" .. c.bg)
        vim.cmd("highlight NetrwCursorLine guibg=" .. c.bg_alt .. " ctermbg=235")
        vim.cmd("setlocal winhighlight=Normal:NetrwNormal,CursorLine:NetrwCursorLine")
      end,
    })

    vim.cmd("highlight Normal guibg=" .. c.bg)
    vim.cmd("highlight NormalNC guibg=" .. c.bg)
    vim.cmd("highlight EndOfBuffer guibg=" .. c.bg)
    vim.cmd("highlight SignColumn guibg=" .. c.bg)

    vim.cmd("highlight NetrwDir guifg=" .. c.blue .. " guibg=" .. c.bg)

    vim.cmd("highlight Pmenu guibg=" .. c.bg .. " guifg=" .. c.fg_bright)
    vim.cmd("highlight PmenuSel guibg=" .. c.bg_light .. " guifg=" .. c.fg_bright)
    vim.cmd("highlight PmenuThumb guibg=" .. c.bg_lighter)
    vim.cmd("highlight PmenuSbar guibg=" .. c.bg_alt)

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
