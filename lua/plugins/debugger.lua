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
          type = "cppdbg",  -- Changed to match adapter name
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

      -- Keybindings for Debugging (commented out as they're now in which-key.nvim)
      -- vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/Continue Debugging" })
      -- vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over" })
      -- vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into" })
      -- vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out" })
      -- vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      -- vim.keymap.set("n", "<Leader>dc", function()
      --   dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      -- end, { desc = "Set Conditional Breakpoint" })
      -- vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Open Debug REPL" })
      -- vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle Debug UI" })
    end
  }
}

