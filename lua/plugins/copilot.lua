return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      prompts = {
        Rename = {
          prompt = 'Please rename the variable correctly in given selection based on context',
          selection = function(source)
            local select = require('CopilotChat.select')
            return select.visual(source)
          end,
        },
        Refactor = {
          prompt = 'Please refactor the code in given selection based on context',
          selection = function(source)
            local select = require('CopilotChat.select')
            return select.visual(source)
          end,
        },
        TutorMotion = {
          prompt = [[
            You are a Neovim tutor. Based on the user's description, suggest the appropriate:
            - Vim motion or command
            - Telescope action (with keybinding if known)
            - LSP command (with keybinding if known)
            
            If multiple options are possible, explain each briefly.
            User's request:
            ]],
        },
        -- New prompts from the first configuration
        Explain = "Please explain how the following code works.",
        Review = "Please review the following code and provide suggestions for improvement.",
        Tests = "Please explain how the selected code works, then generate unit tests for it.",
        FixCode = "Please fix the following code to make it work as intended.",
        FixError = "Please explain the error in the following text and provide a solution.",
        BetterNamings = "Please provide better names for the following variables and functions.",
        Documentation = "Please provide documentation for the following code.",
        SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
        SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
        Summarize = "Please summarize the following text.",
        Spelling = "Please correct any grammar and spelling errors in the following text.",
        Wording = "Please improve the grammar and wording of the following text.",
        Concise = "Please rewrite the following text to make it more concise.",
      },
      -- You can add these additional options if you want
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      mappings = {
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        show_help = {
          normal = "g?",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local user = vim.env.USER or "User"
      user = user:sub(1, 1):upper() .. user:sub(2)
      opts.question_header = "  " .. user .. " "
      opts.answer_header = "  Copilot "

      chat.setup(opts)

      local select = require("CopilotChat.select")
      
      -- Custom commands for different chat modes
      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Get current filetype and set it to markdown if the current filetype is copilot-chat
          local ft = vim.bo.filetype
          if ft == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })

      vim.api.nvim_create_user_command("CopilotTutor", function()
        local input = vim.fn.input("What do you want to do in Neovim? ")
        if input ~= "" then
            chat.ask(opts.prompts.TutorMotion.prompt .. input, {
            window = {
              layout = "float",
              relative = "cursor",
              width = 1,
              height = 0.4,
              row = 1,
            },
          })
        end
      end, {})
    end,
    keys = {
      -- All keybindings converted to <leader>a format
      { "<leader>zc", "<cmd>CopilotChat<cr>", desc = "CopilotChat - Chat with copilot" },
      { "<leader>ze", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>zr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>zf", "<cmd>CopilotChatFix<cr>", desc = "CopilotChat - Fix code issue" },
      { "<leader>zo", "<cmd>CopilotChatOptimize<cr>", mode = "v", desc = "CopilotChat - Optimize code" },
      { "<leader>zd", "<cmd>CopilotChatDocs<cr>", mode = "v", desc = "CopilotChat - Generate Docs" },
      { "<leader>zt", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>zj", "<cmd>CopilotChatCommit<cr>", mode = "n", desc = "CopilotChat - Generate Commit Message" },
      { "<leader>zJ", "<cmd>CopilotChatCommit<cr>", mode = "v", desc = "CopilotChat - Generate Commit Message for Selection" },
      { "<leader>zT", "<cmd>CopilotTutor<cr>", desc = "Copilot Tutor - Ask about motions or commands" },
      
      -- New keybindings from the first configuration
      { "<leader>ap", function() 
          require("CopilotChat").select_prompt({ context = { "buffers" } }) 
        end, 
        desc = "CopilotChat - Prompt actions" 
      },
      { "<leader>ap", function() 
          require("CopilotChat").select_prompt() 
        end, 
        mode = "x", 
        desc = "CopilotChat - Prompt actions" 
      },
      { "<leader>zR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
      { "<leader>zn", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
      { "<leader>zv", ":CopilotChatVisual", mode = "x", desc = "CopilotChat - Open in vertical split" },
      { "<leader>zx", ":CopilotChatInline", mode = "x", desc = "CopilotChat - Inline chat" },
      { "<leader>zi", function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then vim.cmd("CopilotChat " .. input) end
        end, 
        desc = "CopilotChat - Ask input" 
      },
      { "<leader>am", "<cmd>CopilotChatCommit<cr>", desc = "CopilotChat - Generate commit message for all changes" },
      { "<leader>aq", function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then vim.cmd("CopilotChatBuffer " .. input) end
        end, 
        desc = "CopilotChat - Quick chat" 
      },
      { "<leader>zE", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic" },
      { "<leader>zl", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
      { "<leader>zV", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
      { "<leader>z?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
      { "<leader>za", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - Select Agents" },
    },
  },
}
