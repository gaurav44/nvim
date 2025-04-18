return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",  -- UI for DAP
      "theHamsta/nvim-dap-virtual-text", -- Inline debug info
      "nvim-telescope/telescope-dap.nvim", -- Telescope integration
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local json = require("lunajson")
      local function load_debug_config()
        local file = io.open("debug.json", "r")
        if not file then return {} end
        local content = file:read("*a")
        file:close()
        return json.decode(content) or {}
      end

      local debug_config = load_debug_config()

      -- C++ Debugger (gdb/lldb)
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = '/home/gaurav/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }

      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "cppdbg",
          request = "launch",
          program = debug_config.program or function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = debug_config.args or {},
          cwd = debug_config.cwd or "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = false
        }
      }

      -- Add the same configurations for C
      dap.configurations.c = dap.configurations.cpp

      -- DAP UI Setup
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Auto open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  }
}

