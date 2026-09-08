-- Raw hand-written SQL with no ORM means schema lookup would otherwise be a
-- context switch to psql. dadbod-completion registers itself as an nvim-cmp
-- source, so this module loads after cmp in the registry.
return {
  src = "tpope/vim-dadbod",
  deps = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  setup = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_winwidth = 40
    -- keeps connection strings out of the config; DBUI reads this directory
    vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("dadbod_cmp", { clear = true }),
      pattern = { "sql", "mysql", "plsql" },
      callback = function()
        require("cmp").setup.buffer({
          sources = {
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
            { name = "luasnip" },
          },
        })
      end,
    })

    vim.keymap.set("n", "<leader>vd", "<cmd>DBUIToggle<cr>", { desc = "Toggle database UI" })
  end,
}
