return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui", -- UI for DAP
    "jay-babu/mason-nvim-dap.nvim", -- Manage debuggers via Mason
    "mfussenegger/nvim-dap-vscode-js", -- Debugger for JS/TS
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("dapui").setup()
    require("mason-nvim-dap").setup({
      ensure_installed = { "js-debug-adapter", "dart-debug-adapter", "bash-debug-adapter" },
    })
    local dap, dapui = require("dap"), require("dapui")
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
