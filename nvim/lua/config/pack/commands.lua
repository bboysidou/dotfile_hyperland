-- Replacements for the :Lazy UI. Neovim 0.13 ships :packupdate and :packdel
-- natively; guard so these never collide once this machine gets them.
if vim.fn.exists(":packupdate") ~= 0 then
  return
end

local function names(args)
  return #args.fargs > 0 and args.fargs or nil
end

vim.api.nvim_create_user_command("PackUpdate", function(args)
  vim.pack.update(names(args), { force = args.bang })
end, { nargs = "*", bang = true, desc = "Update plugins (bang skips confirmation)" })

vim.api.nvim_create_user_command("PackStatus", function(args)
  vim.pack.update(names(args), { offline = true })
end, { nargs = "*", desc = "Review installed plugins without fetching" })

vim.api.nvim_create_user_command("PackDel", function(args)
  vim.pack.del(args.fargs, { force = args.bang })
end, { nargs = "+", bang = true, desc = "Remove plugins from disk" })

vim.keymap.set("n", "<leader>pu", "<cmd>PackUpdate<cr>", { desc = "Update plugins" })
vim.keymap.set("n", "<leader>ps", "<cmd>PackStatus<cr>", { desc = "Plugin status" })
