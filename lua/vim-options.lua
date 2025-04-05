vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set relativenumber")
vim.g.mapleader = " "
vim.o.foldmethod = 'indent'
vim.o.foldlevelstart = 99
--vim.cmd('filetype plugin indent on')
--vim.api.nvim_set_keymap('n', '<space>', 'za', { noremap = true, silent = true })  -- Toggle fold
--vim.api.nvim_set_keymap('n', 'zc', 'zM', { noremap = true, silent = true })       -- Close all folds
--vim.api.nvim_set_keymap('n', 'zo', 'zR', { noremap = true, silent = true })       -- Open all folds

function ToggleTheme()
  if vim.g.colors_name == "catpuccin" then
    vim.cmd("colorscheme catpuccin")
  else 
    vim.cmd("colorscheme gruvbox")
  end
end

-- Theme toggle keybinding now in which-key.nvim
-- vim.keymap.set('n', '<leader>tt', ToggleTheme,
--   { noremap = true, silent = true, desc = "Toggle between Gruvbox and catpuccin" })

vim.o.cursorline = true

vim.keymap.set("i", "<C-w>", function()
  local col = vim.api.nvim_win_get_cursor(0)[2];
  local line = vim.api.nvim_get_current_line()

  local before_cursor = col > 0 and line:sub(col, col):match("[%w_]")
  local after_cursor = line:sub(col + 1, col + 1):match("[%w_]")

  if before_cursor or after_cursor then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>dw", true, true, true), "n", false)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>", true, true, true), "n", false)
  end
end, { noremap = true, silent = true })

vim.opt.clipboard = "unnamedplus"

-- Quickfix navigation keybindings now in which-key.nvim
-- vim.keymap.set("n", "B", ":cprev<CR>", { noremap = true, silent = true, desc = "Previous item in Quickfix" })
-- vim.keymap.set("n", "P", ":cnext<CR>", { noremap = true, silent = true, desc = "Next item in Quickfix" })
-- vim.keymap.set("n", "<leader>q", function()
--   local is_open = false
--   for _, win in ipairs(vim.api.nvim_list_wins()) do
--     if vim.api.nvim_win_get_config(win).relative == "" and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "qf" then
--       vim.cmd("cclose")
--       is_open = true
--       break
--     end
--   end
--   if not is_open then vim.cmd("copen") end
-- end, { noremap = true, silent = true, desc = "Toggle Quickfix List" })

-- Current buffer fuzzy search now in which-key.nvim
-- vim.keymap.set("n", "<leader>ss", function()
--   require('telescope.builtin').current_buffer_fuzzy_find()
-- end, { noremap = true, silent = true, desc = "Fuzzy Find in Current Buffer" })

-- vim.opt.guifont = "Hack Nerd Font:h12"