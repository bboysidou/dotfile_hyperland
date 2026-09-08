return {
  src = "wa11breaker/flutter-bloc.nvim",
  deps = { "nvimtools/none-ls.nvim" },
  setup = function()
    require("flutter-bloc").setup({
      bloc_type = "default",
      use_sealed_classes = false,
      enable_code_actions = true,
    })
  end,
}
