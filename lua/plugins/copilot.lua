return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      model = "gpt-4",
      window = {
        layout = "vertical",
        width = 0.5,
      },
    },
    keys = {
      {
        "zm",
        "<cmd>CopilotChatModels<cr>",
        desc = "CopilotChat - Select Model",
      },
      {
        "zc",
        "<cmd>CopilotChat<cr>",
        desc = "CopilotChat - Open Chat",
      },
      {
        "ze",
        "<cmd>CopilotChatExplain<cr>",
        mode = "v",
        desc = "CopilotChat - Explain selected code",
      },
      {
        "zl",
        "<cmd>CopilotChatReset<cr>",
        desc = "CopilotChat - Reset Chat",
      },
      config = function(_, opts)
        require("CopilotChat").setup(opts)
      end,
    }
  },
}
