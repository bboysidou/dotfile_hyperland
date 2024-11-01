-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt

vim.g.skip_ts_context_commentstring_module = true

opt.guicursor = ""
opt.background = "dark"

-- backspace
opt.backspace = "indent,eol,start"

-- editor
opt.scrolloff = 10
