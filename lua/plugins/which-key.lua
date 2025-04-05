return {
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        key_labels = {
          ["<space>"] = "Space",
          ["<leader>"] = "Leader",
        },
        icons = {
          breadcrumb = "»",
          separator = "",
          group = "+",
        },
        window = {
          border = "rounded",
          winhighlight = {
            border = "Normal",
            background = "Normal",
          },
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 }
        },
        ignore_missing = true,
        show_help = true,
        triggers = "auto",
        triggers_nowait = false,
        disable = {},
        side_labels = true,
        mappings = {
          ["z"] = {
            name = "Copilot",
            c = { "<cmd>CopilotChat<cr>", "Chat with copilot" },
            e = { "<cmd>CopilotChatExplain<cr>", "Explain code" },
            r = { "<cmd>CopilotChatReview<cr>", "Review code" },
            f = { "<cmd>CopilotChatFix<cr>", "Fix code issue" },
            R = { "<cmd>CopilotChatRefactor<cr>", "Refactor code" },
            n = { "<cmd>CopilotChatBetterNamings<cr>", "Better Naming" },
            i = {
              function()
                local input = vim.fn.input("Ask Copilot: ")
                if input ~= "" then vim.cmd("CopilotChat " .. input) end
              end,
              "Ask input",
            },
            m = { "<cmd>CopilotChatCommit<cr>", "Generate commit message" },
            q = {
              function()
                local input = vim.fn.input("Quick Chat: ")
                if input ~= "" then vim.cmd("CopilotChatBuffer " .. input) end
              end,
              "Quick chat",
            },
            E = { "<cmd>CopilotChatFixError<cr>", "Fix Diagnostic" },
            l = { "<cmd>CopilotChatReset<cr>", "Clear buffer and chat history" },
            V = { "<cmd>CopilotChatToggle<cr>", "Toggle" },
            ["?"] = { "<cmd>CopilotChatModels<cr>", "Select Models" },
            a = { "<cmd>CopilotChatAgents<cr>", "Select Agents" },
          },
          ["d"] = {
            name = "Debug",
            b = { function() require('dap').toggle_breakpoint() end, "Toggle Breakpoint" },
            c = { function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "Conditional Breakpoint" },
            r = { function() require('dap').repl.open() end, "Open REPL" },
            u = { function() require('dapui').toggle() end, "Toggle UI" },
          },
          ["g"] = {
            name = "LSP",
            d = { function() vim.lsp.buf.definition() end, "Go to Definition" },
            t = { function() vim.lsp.buf.type_definition() end, "Go to Type Definition" },
            D = { function() vim.lsp.buf.declaration() end, "Go to Declaration" },
            r = { function() vim.lsp.buf.rename() end, "Rename Symbol" },
            R = { function() vim.lsp.buf.references() end, "Find References" },
            k = { function() vim.diagnostic.open_float() end, "Show Diagnostic in Float" },
            s = { function() require('telescope.builtin').lsp_document_symbols() end, "Document Symbols" },
            a = { function() vim.lsp.buf.code_action() end, "Code Action" },
            f = { function() vim.lsp.buf.format() end, "Format Document" },
          },
          ["f"] = {
            name = "Telescope",
            f = { function() require('telescope.builtin').find_files() end, "Find Files" },
            g = { function() require('telescope.builtin').live_grep() end, "Live Grep" },
            s = { function() require('telescope.builtin').grep_string() end, "Grep String" },
            b = { function() require('telescope.builtin').buffers() end, "Find Buffers" },
          },
          ["t"] = {
            name = "Tests/Terminal",
            c = { "<cmd>GTestFuzzyFind<CR>", "Select GTest Case" },
            a = { "<cmd>GTestRunAllExceptDebug<CR>", "Run All Tests Except Debug" },
            d = { "<cmd>GTestRunOnlyDebug<CR>", "Run Only Debug Tests" },
            b = { function()
              vim.cmd('silent !tmux split-window -h "mkdir -p build install && clear"')
            end, "Open Terminal with Build Dirs" },
            f = { function()
              require('telescope.builtin').lsp_document_symbols({ symbols = { "function", "method" } })
            end, "Find Functions" },
          },
          ["c"] = {
            name = "CMake",
            m = { function() require('cmake-mappings').select_preset() end, "Select CMake Preset" },
          },
          ["b"] = {
            name = "Build/Buffer",
            r = { function()
              vim.cmd('silent !tmux send-keys -t "{last}" "cmake --build build --parallel 36" Enter')
            end, "Build Release" },
            d = { function()
              vim.cmd('silent !tmux send-keys -t "{last}" "cmake --build build-debug --parallel 36" Enter')
            end, "Build Debug" },
            n = { ":bnext<CR>", "Next Buffer" },
            p = { ":bprevious<CR>", "Previous Buffer" },
          },
          ["o"] = { "<cmd>Outline<cr>", "Toggle Outline" },
          ["s"] = {
            name = "Search",
            s = { function() require('telescope.builtin').current_buffer_fuzzy_find() end, "Search in Current Buffer" },
          },
          ["r"] = {
            name = "Rename",
            n = { function() vim.lsp.buf.rename() end, "Rename Symbol" },
          },
        },
      }

      -- Register keymaps outside of which-key setup
      local wk = require("which-key")
      
      -- Define keymaps that already exist in your configuration
      wk.register({
        -- Telescope mappings
        ["<leader>ff"] = { function() require('telescope.builtin').find_files() end, "Find Files" },
        ["<leader>fg"] = { function() require('telescope.builtin').live_grep() end, "Live Grep" },
        ["<leader>fs"] = { function() require('telescope.builtin').grep_string() end, "Grep String" },
        ["<leader>tf"] = { function() require('telescope.builtin').lsp_document_symbols({ symbols = { 'function', 'method' } }) end, "Find Functions" },
        ["<leader>fb"] = { function() require('telescope.builtin').buffers() end, "Find Buffers" },
        ["<leader>ss"] = { function() require('telescope.builtin').current_buffer_fuzzy_find() end, "Search in Current Buffer" },
        
        -- LSP mappings
        ["<leader>gd"] = { function() vim.lsp.buf.definition() end, "Go to Definition" },
        ["<leader>gt"] = { function() vim.lsp.buf.type_definition() end, "Go to Type Definition" },
        ["<leader>gD"] = { function() vim.lsp.buf.declaration() end, "Go to Declaration" },
        ["K"] = { function() vim.lsp.buf.hover() end, "Show Hover" },
        ["<leader>rn"] = { function() vim.lsp.buf.rename() end, "Rename Symbol" },
        ["<leader>gr"] = { function() vim.lsp.buf.references() end, "Find References" },
        ["<leader>gf"] = { function() vim.lsp.buf.format() end, "Format Document" },
        ["<leader>k"] = { function() vim.diagnostic.open_float() end, "Show Diagnostic" },
        ["[d"] = { function() vim.diagnostic.goto_next() end, "Next Diagnostic" },
        ["]d"] = { function() vim.diagnostic.goto_prev() end, "Previous Diagnostic" },
        ["<leader>ds"] = { function() require('telescope.builtin').lsp_document_symbols() end, "Document Symbols" },
        ["<leader>ca"] = { function() vim.lsp.buf.code_action() end, "Code Action" },
        
        -- Buffer navigation
        ["<leader>bn"] = { ":bnext<CR>", "Next Buffer" },
        ["<leader>bp"] = { ":bprevious<CR>", "Previous Buffer" },
        
        -- Outline
        ["<leader>o"] = { "<cmd>Outline<cr>", "Toggle Outline" },
        
        -- CMake mappings (updated to match cmake-mappings.lua)
        ["<leader>cm"] = { function() require('cmake-mappings').select_preset() end, "Select CMake Preset" },
        ["<leader>br"] = { function()
          vim.cmd('silent !tmux send-keys -t "{last}" "cmake --build build --parallel 36" Enter')
        end, "Build Release" },
        ["<leader>bd"] = { function()
          vim.cmd('silent !tmux send-keys -t "{last}" "cmake --build build-debug --parallel 36" Enter')
        end, "Build Debug" },
        ["<leader>tb"] = { function()
          vim.cmd('silent !tmux split-window -h "mkdir -p build install && clear"')
        end, "Open Terminal with Build Dirs" },
        
        -- GTest mappings
        ["<leader>tc"] = { "<cmd>GTestFuzzyFind<CR>", "Select GTest Case" },
        ["<leader>ta"] = { "<cmd>GTestRunAllExceptDebug<CR>", "Run All Tests Except Debug" },
        ["<leader>td"] = { "<cmd>GTestRunOnlyDebug<CR>", "Run Only Debug Tests" },

        -- Quickfix list navigation
        ["B"] = { ":cprev<CR>", "Previous Item in Quickfix" },
        ["P"] = { ":cnext<CR>", "Next Item in Quickfix" },
        ["<leader>q"] = { function()
          local is_open = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(win).relative == "" and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "qf" then
              vim.cmd("cclose")
              is_open = true
              break
            end
          end
          if not is_open then vim.cmd("copen") end
        end, "Toggle Quickfix List" },

        -- F-key mappings for debug
        ["<F5>"] = { function() require("dap").continue() end, "Start/Continue Debugging" },
        ["<F10>"] = { function() require("dap").step_over() end, "Step Over" },
        ["<F11>"] = { function() require("dap").step_into() end, "Step Into" },
        ["<F12>"] = { function() require("dap").step_out() end, "Step Out" },
        ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint" },
        ["<leader>dc"] = { function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Conditional Breakpoint" },
        ["<leader>dr"] = { function() require("dap").repl.open() end, "Open Debug REPL" },
        ["<leader>du"] = { function() require("dapui").toggle() end, "Toggle Debug UI" },
        
        -- Theme toggle
        ["<leader>tt"] = { function() 
          if vim.g.colors_name == "catpuccin" then
            vim.cmd("colorscheme catpuccin")
          else 
            vim.cmd("colorscheme gruvbox")
          end
        end, "Toggle Theme" },
      })
    end
  }
}