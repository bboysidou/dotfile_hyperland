-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- variable declaration
keymap.set("x", "<leader>p", '"_dP') -- past without overriding the register
keymap.set("n", "<A-down>", ":m .+1<CR>==") -- move line up(n)
keymap.set("n", "<A-up>", ":m .-2<CR>==") -- move line down(n)
keymap.set("v", "<A-down>", ":m '>+1<CR>gv=gv") -- move line up(v)
keymap.set("v", "<A-up>", ":m '<-2<CR>gv=gv") -- move line down(v)
-- window management
keymap.set("n", "sv", "<C-w>v") -- split window vertically
keymap.set("n", "sh", "<C-w>s") -- split window horizontally
keymap.set("n", "se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- bufferline
keymap.set({ "n", "v", "i" }, "<A-l>", "<CMD>BufferLineCycleNext<CR>") -- cycle through buffers
keymap.set({ "n", "v", "i" }, "<A-h>", "<CMD>BufferLineCyclePrev<CR>") -- cycle through buffers
keymap.set({ "n", "v", "i" }, "<A-a>", "<CMD>BufferLineCloseOthers<CR>") -- close all other buffers
keymap.set({ "n", "v", "i" }, "<leader>q", ":bdelete<CR>", { desc = "close buffer", silent = true })
-- vim.keymap.set('n', 'gb', '<CMD>BufferLinePick<CR>')
-- vim.keymap.set("n", "<leader>ts", "<CMD>BufferLinePickClose<CR>")
-- vim.keymap.set('n', ']b', '<CMD>BufferLineMoveNext<CR>')
-- vim.keymap.set('n', '[b', '<CMD>BufferLineMovePrev<CR>')
-- vim.keymap.set('n', 'gs', '<CMD>BufferLineSortByDirectory<CR>')

-- harpoon
keymap.set("n", "<leader>a", function()
  require("harpoon"):list():add()
end, { desc = "Mark file with harpoon" })

keymap.set("n", "<leader>hh", function()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Go to previous harpoon mark" })

for i = 1, 5 do
  keymap.set("n", "<leader>" .. i, function()
    require("harpoon"):list():select(i)
  end, { desc = "Harpoon to File " .. i })
end

-- flutter
keymap.set({ "n", "v", "i" }, "<A-f>", ":FlutterOutlineToggle<CR>")

-- file
keymap.set("n", "n", "nzzzv") -- search down and center the view
keymap.set("n", "N", "Nzzzv") -- search up center the view
keymap.set({ "n", "v", "i" }, "<C-d>", "<C-d>zz") -- move half page up and center the view
keymap.set({ "n", "v", "i" }, "<C-u>", "<C-u>zz") -- move half page down and center the view
keymap.set({ "n", "v", "i" }, "<C-s>", "<ESC>:w<CR>", { desc = "Save file", silent = true }) -- save the file
keymap.set({ "n", "v", "i" }, "<C-w>", "<ESC>:q!<CR>", { desc = "Quit file", silent = true }) -- close the file
keymap.set({ "n", "v", "i" }, "<C-down>", "5jzz") -- jump 5 down lines
keymap.set({ "n", "v", "i" }, "<C-up>", "5kzz") -- jump 5 up lines
