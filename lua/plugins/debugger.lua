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

      local function get_launch_configurations()
        local status_ok, vscode = pcall(require, 'dap.ext.vscode')
        if not status_ok then
            print("Error: dap.ext.vscode not found. Ensure nvim-dap is installed.")
            return nil
        end
        return vscode.getconfigs()
      end

      -- C++ Debugger (gdb/lldb)
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = '/home/gaurav/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }

      dap.configurations.cpp = get_launch_configurations()

      -- dap.configurations.cpp = {
      --   {
      --     name = "Launch",
      --     type = "cppdbg",
      --     request = "launch",
      --     program = debug_config.program or function()
      --       return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      --     end,
      --     args = debug_config.args or {},
      --     cwd = debug_config.cwd or "${workspaceFolder}",
      --     stopOnEntry = false,
      --     runInTerminal = false
      --   }
      -- }

      -- Add the same configurations for C
      dap.configurations.c = dap.configurations.cpp

      -- DAP UI Setup
       -- DAP UI Setup with specific configuration
       dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
        mappings = {
          edit = "e",
          expand = {"<CR>", "<2-LeftMouse>"}, -- Use Enter or double-click
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t",
        },
      })
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

      -- Leader keymaps for DAP
      vim.keymap.set("n", "<leader>dr", function()
        -- Create a vertical split
        vim.cmd("vsplit")
        -- Open the DAP REPL in the new split
        require("dap").repl.open()
      end, { desc = "Open DAP REPL in vertical split" })

      -- These mappings help navigate in DAP UI windows
      local function set_dap_keymaps()
        -- Jump to location when clicking on stack frames
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "dap-repl,dapui_scopes,dapui_breakpoints,dapui_stacks,dapui_watches",
          callback = function()
            vim.keymap.set("n", "<CR>", function()
              require("dapui").eval()
            end, { buffer = true })
            
            -- Enable clicking on stack frames
            vim.keymap.set("n", "<2-LeftMouse>", function()
              -- If we're in stacks buffer, jump to the frame
              local win_id = vim.api.nvim_get_current_win()
              local buf_id = vim.api.nvim_win_get_buf(win_id)
              local buf_name = vim.api.nvim_buf_get_name(buf_id)
              
              if buf_name:match("DAP Stacks$") then
                require("dap.ui").trigger_actions({ mode = "first" })
                return
              end
              require("dapui").eval()
            end, { buffer = true })
          end
        })
      end
      
      set_dap_keymaps()

    end
  }
}

