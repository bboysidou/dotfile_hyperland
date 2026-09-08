return {
  src = "ThePrimeagen/harpoon",
  version = "harpoon2",
  setup = function()
    require("harpoon"):setup({
      settings = {
        save_on_toggle = true,
      },
    })
  end,
}
