return {
  src = "mfussenegger/nvim-dap",
  deps = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "jay-babu/mason-nvim-dap.nvim",
    "mfussenegger/nvim-dap-vscode-js",
  },
  setup = function()
    local dap, dapui = require("dap"), require("dapui")

    dapui.setup()

    require("mason-nvim-dap").setup({
      ensure_installed = { "js-debug-adapter", "dart-debug-adapter", "bash-debug-adapter" },
    })

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
