return {
  "shortcuts/no-neck-pain.nvim",
  version = "*",
  config = function()
    require("no-neck-pain").setup({
      -- Optional: Configure settings
      width = 120,
      autocmds = {
        enableOnVimEnter = false,
      },
    })
    
    -- Add keybinding
    vim.keymap.set("n", "<leader>np", ":NoNeckPain<CR>", { desc = "Toggle No Neck Pain" })
  end,
}
