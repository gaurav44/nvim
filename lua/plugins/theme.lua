           
 return {
  --  "catppuccin/nvim",
  --  name = "catppuccin",
  --  priority = 1000,
  --  config = function()
  --    vim.cmd.colorscheme "catppuccin"
  --  end
   
   "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      require('vscode').setup({
        -- Optional: customize the theme
        transparent = false,
        italic_comments = true,
        disable_nvimtree_bg = true,
      })
      vim.cmd.colorscheme "vscode"
    end
  
}
