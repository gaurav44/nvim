return {  
  -- Diffview for advanced diff viewing
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("diffview").setup({
        use_icons = true,
      })
    end
  },
  
  -- Gitsigns for in-line git information
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          -- Navigation keymaps will be set in which-key
        end,
      })
    end
  },
}