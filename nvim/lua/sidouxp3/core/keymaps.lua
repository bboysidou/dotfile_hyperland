--set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- variable declaration
keymap.set("x", "<leader>p", '"_dP') -- past without overriding the register
keymap.set("n", "<A-down>", ":m .+1<CR>==") -- move line up(n)
keymap.set("n", "<A-up>", ":m .-2<CR>==") -- move line down(n)
keymap.set("v", "<A-down>", ":m '>+1<CR>gv=gv") -- move line up(v)
keymap.set("v", "<A-up>", ":m '<-2<CR>gv=gv") -- move line down(v)
-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

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
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- bufferline
keymap.set({ "n", "v", "i" }, "<A-l>", "<CMD>BufferLineCycleNext<CR>")
keymap.set({ "n", "v", "i" }, "<A-h>", "<CMD>BufferLineCyclePrev<CR>")
keymap.set({ "n", "v", "i" }, "<leader>q", ":bdelete<CR>")
-- vim.keymap.set('n', 'gb', '<CMD>BufferLinePick<CR>')
-- vim.keymap.set("n", "<leader>ts", "<CMD>BufferLinePickClose<CR>")
-- vim.keymap.set('n', ']b', '<CMD>BufferLineMoveNext<CR>')
-- vim.keymap.set('n', '[b', '<CMD>BufferLineMovePrev<CR>')
-- vim.keymap.set('n', 'gs', '<CMD>BufferLineSortByDirectory<CR>')

-- flutter
keymap.set({ "n", "v", "i" }, "<A-f>", ":FlutterOutlineToggle<CR>")

-- dbui
keymap.set("n", "<leader>db", ":DBUIToggle<CR>")

-- file
keymap.set("n", "n", "nzzzv") -- search down and center the view
keymap.set("n", "N", "Nzzzv") -- search up center the view
keymap.set({ "n", "v", "i" }, "<C-d>", "<C-d>zz") -- move half page up and center the view
keymap.set({ "n", "v", "i" }, "<C-u>", "<C-u>zz") -- move half page down and center the view
keymap.set({ "n", "v", "i" }, "<C-s>", "<ESC>:w<CR>") -- save the file
keymap.set({ "n", "v", "i" }, "<C-w>", "<ESC>:q!<CR>") -- close the file
keymap.set({ "n", "v", "i" }, "<C-down>", "5jzz") -- jump 5 down lines
keymap.set({ "n", "v", "i" }, "<C-up>", "5kzz") -- jump 5 up lines

-- VIM REST CONSOLE
keymap.set("n", "<C-x>", ":call VrcQuery()<CR>") -- RUN REST QUERY
