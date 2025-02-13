--set leader key to space
vim.g.mapleader = " "

function toggle_netrw()
  local netrw_buf = nil

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "netrw" then
      netrw_buf = buf
      break
    end
  end

  if netrw_buf then
    vim.cmd("bd! " .. netrw_buf)
  else
    vim.cmd("Explore")
  end
end

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

-- file-tree
keymap.set("n", "<leader>e", ":lua toggle_netrw()<CR>", { silent = true }) -- toggle file explorer
-- keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>") -- list TODOs comments

-- bufferline
keymap.set({ "n", "v", "i" }, "<A-l>", "<CMD>BufferLineCycleNext<CR>") -- cycle through buffers
keymap.set({ "n", "v", "i" }, "<A-h>", "<CMD>BufferLineCyclePrev<CR>") -- cycle through buffers
keymap.set({ "n", "v", "i" }, "<A-a>", "<CMD>BufferLineCloseOthers<CR>") -- close all other buffers
keymap.set({ "n", "v", "i" }, "<leader>q", ":bdelete<CR>")
-- vim.keymap.set('n', 'gb', '<CMD>BufferLinePick<CR>')
-- vim.keymap.set("n", "<leader>ts", "<CMD>BufferLinePickClose<CR>")
-- vim.keymap.set('n', ']b', '<CMD>BufferLineMoveNext<CR>')
-- vim.keymap.set('n', '[b', '<CMD>BufferLineMovePrev<CR>')
-- vim.keymap.set('n', 'gs', '<CMD>BufferLineSortByDirectory<CR>')

-- harpoon
keymap.set("n", "<leader>a", ":lua require('harpoon.mark').add_file()<cr>", { desc = "Mark file with harpoon" })
keymap.set("n", "<leader>nn", ":lua require('harpoon.ui').nav_next()<cr>", { desc = "Go to next harpoon mark" })
keymap.set("n", "<leader>pp", ":lua require('harpoon.ui').nav_prev()<cr>", { desc = "Go to previous harpoon mark" })
-- keymap.set("n", "<C-h>", ":lua require('harpoon.ui').nav_file(1)<cr>", { desc = "navigate to the 1 file" })
keymap.set("n", "<leader>y", ":lua require('harpoon.ui').nav_file(1)<cr>", { desc = "navigate to the 1 file" })
keymap.set("n", "<leader>u", ":lua require('harpoon.ui').nav_file(2)<cr>", { desc = "navigate to the 2 file" })
keymap.set("n", "<leader>i", ":lua require('harpoon.ui').nav_file(3)<cr>", { desc = "navigate to the 3 file" })
keymap.set("n", "<leader>o", ":lua require('harpoon.ui').nav_file(4)<cr>", { desc = "navigate to the 4 file" })
keymap.set(
  "n",
  "<leader>hh",
  ":lua require('harpoon.ui').toggle_quick_menu()<cr>",
  { desc = "Go to previous harpoon mark" }
)

-- flutter
keymap.set({ "n", "v", "i" }, "<A-f>", ":FlutterOutlineToggle<CR>")

-- file
keymap.set("n", "n", "nzzzv") -- search down and center the view
keymap.set("n", "N", "Nzzzv") -- search up center the view
keymap.set({ "n", "v", "i" }, "<C-d>", "<C-d>zz") -- move half page up and center the view
keymap.set({ "n", "v", "i" }, "<C-u>", "<C-u>zz") -- move half page down and center the view
keymap.set({ "n", "v", "i" }, "<C-s>", "<ESC>:w<CR>") -- save the file
keymap.set({ "n", "v", "i" }, "<C-w>", "<ESC>:q!<CR>") -- close the file
keymap.set({ "n", "v", "i" }, "<C-down>", "5jzz") -- jump 5 down lines
keymap.set({ "n", "v", "i" }, "<C-up>", "5kzz") -- jump 5 up lines

-- debugger
keymap.set("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle breakpoint" })
keymap.set("n", "<leader>du", ":lua require'dapui'.toggle()<CR>", { desc = "Toggle breakpoint" })
keymap.set("n", "<leader>dn", ":lua require'dap'.continue()<CR>", { desc = "Continue debugging" })
keymap.set("n", "<leader>do", ":lua require'dap'.step_over()<CR>", { desc = "Step over" })
keymap.set("n", "<leader>di", ":lua require'dap'.step_into()<CR>", { desc = "Step into" })
keymap.set("n", "<leader>de", ":lua require'dap'.step_out()<CR>", { desc = "Step out" })
keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", { desc = "Open REPL" })
keymap.set("n", "<leader>dl", ":lua require'dap'.run_last()<CR>", { desc = "Run last" })
