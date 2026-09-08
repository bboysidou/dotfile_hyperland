-- vim.diagnostic.config lived here under lazy.nvim, but lsp-zero also set sign
-- text from lsp/lsp-config.lua. Two calls meant the later one clobbered the
-- other's keys, so all diagnostic config is now consolidated in lspconfig.lua.
return {
  src = "hrsh7th/nvim-cmp",
  deps = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    { src = "L3MON4D3/LuaSnip", version = vim.version.range("2"), build = { "make", "install_jsregexp" } },
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
  setup = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
      formatting = {
        fields = { "abbr", "kind", "menu" },
        expandable_indicator = true,
        format = lspkind.cmp_format({
          maxwidth = 80,
          ellipsis_char = "...",
          symbol_map = {
            Function = "󰊕",
            Variable = "",
            Class = "󰠱",
            Snippet = "",
          },
        }),
      },
    })
  end,
}
