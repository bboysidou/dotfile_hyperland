-- vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- Declare a variable
vim.g.skip_ts_context_commentstring_module = true
vim.opt.autochdir = false

opt.guicursor = ""
opt.winborder = "rounded"
-- line numbers
opt.relativenumber = true
opt.number = true

-- tab & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
-- clipboard
opt.clipboard:append("unnamedplus")

--split windows
opt.splitright = true
opt.splitbelow = true

-- backspace
opt.backspace = "indent,eol,start"

-- editor
opt.scrolloff = 10
