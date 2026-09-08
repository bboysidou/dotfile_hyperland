-- Sessions are keyed by cwd, so each project restores its own buffers, window
-- layout and marks.
return {
  src = "folke/persistence.nvim",
  setup = function()
    local persistence = require("persistence")
    persistence.setup()

    vim.keymap.set("n", "<leader>vs", function()
      persistence.load()
    end, { desc = "Restore session for this directory" })

    vim.keymap.set("n", "<leader>vl", function()
      persistence.load({ last = true })
    end, { desc = "Restore last session" })

    vim.keymap.set("n", "<leader>vq", function()
      persistence.stop()
    end, { desc = "Quit without saving session" })
  end,
}
