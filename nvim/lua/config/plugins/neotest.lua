-- Tests are the definition of done in this workspace but there was no way to
-- run one without leaving the editor. Debugging a failing test reuses the
-- existing nvim-dap setup, so this module loads after dap in the registry.
--
-- Adapters cover Flutter (neotest-dart) and Vitest. `bun test` has no
-- first-party adapter yet, so backend suites still run from a terminal.
return {
  src = "nvim-neotest/neotest",
  deps = {
    "antoinemadec/FixCursorHold.nvim",
    "sidlatau/neotest-dart",
    "marilari88/neotest-vitest",
  },
  setup = function()
    local neotest = require("neotest")

    neotest.setup({
      adapters = {
        require("neotest-dart")({
          command = "flutter",
          use_lsp = true,
        }),
        require("neotest-vitest"),
      },
      output = { open_on_run = false },
    })

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc })
    end

    map("<leader>Tt", function() neotest.run.run() end, "Test: run nearest")
    map("<leader>Tf", function() neotest.run.run(vim.fn.expand("%")) end, "Test: run file")
    map("<leader>Td", function() neotest.run.run({ strategy = "dap" }) end, "Test: debug nearest")
    map("<leader>Ts", function() neotest.summary.toggle() end, "Test: toggle summary")
    map("<leader>To", function() neotest.output_panel.toggle() end, "Test: toggle output panel")
    map("<leader>TS", function() neotest.run.stop() end, "Test: stop")
  end,
}
