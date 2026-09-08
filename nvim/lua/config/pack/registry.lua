-- Load order for every managed plugin. This list IS the dependency graph:
-- vim.pack resolves nothing, so ordering that lazy.nvim inferred from 18
-- nested `dependencies` tables is written down here explicitly.
--
-- Entries are module names under `config.plugins`. A module's own `deps` ride
-- along with it and are not listed here.
return {
  -- shared infrastructure: no single owner
  "plenary",
  "devicons",

  -- colorscheme early; replaces lazy's priority = 1000
  "colorscheme",

  -- treesitter before textobjects: textobject queries need the parser API
  "treesitter",
  "ts_autotag",
  "treesitter_textobjects",
  "render_markdown",

  -- mason registers servers before lspconfig configures them
  "mason",
  "lsp_file_operations",
  "lspconfig",

  -- flutter_tools reads cmp_nvim_lsp capabilities, provided by lspconfig's deps
  "flutter_bloc",
  "flutter_tools",

  -- autopairs hooks cmp's confirm_done event, so it must follow cmp;
  -- dadbod-completion registers itself as a cmp source
  "cmp",
  "autopairs",
  "dadbod",

  "codeium",
  "conform",
  "lint",

  -- trouble before telescope: telescope's config requires trouble.sources.telescope
  "todo_comments",
  "trouble",
  "telescope",
  "harpoon",

  "gitsigns",
  "diffview",
  "persistence",
  "undotree",
  "comment",
  "bufferline",
  "lualine",
  "fidget",
  "dressing",
  "tmux_navigator",

  -- neotest debugs a failing test through nvim-dap's strategy
  "dap",
  "neotest",
}
