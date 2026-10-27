local c = require("config.colors")

local HIGHLIGHTS = {
  FrameLine = { fg = c.border },
  FrameTabActive = { fg = c.fg_bright, bold = true },
  FrameTabInactive = { fg = c.fg_muted },
  StatusLine = { fg = c.border, bg = "NONE" },
  StatusLineNC = { fg = c.border, bg = "NONE" },
  TabLineFill = { bg = "NONE" },
}

local function apply_highlights()
  for group, spec in pairs(HIGHLIGHTS) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

apply_highlights()

local group = vim.api.nvim_create_augroup("FrameUi", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = apply_highlights })
vim.api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged" }, {
  group = group,
  command = "redrawstatus",
})
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "GitSignsUpdate",
  command = "redrawstatus",
})
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufModifiedSet" }, {
  group = group,
  command = "redrawtabline",
})

vim.opt.fillchars:append({ stl = "─", stlnc = "─" })
vim.o.laststatus = 3
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.require'config.ui.tabline'.render()"
vim.o.statusline = "%!v:lua.require'config.ui.statusline'.render()"
