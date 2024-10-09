vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set relativenumber")
vim.g.mapleader = " "
vim.o.foldmethod = 'syntax'
vim.o.foldlevelstart = 99
vim.cmd('filetype plugin indent on')
vim.api.nvim_set_keymap('n', '<space>', 'za', { noremap = true, silent = true })  -- Toggle fold
vim.api.nvim_set_keymap('n', 'zc', 'zM', { noremap = true, silent = true })       -- Close all folds
vim.api.nvim_set_keymap('n', 'zo', 'zR', { noremap = true, silent = true })       -- Open all folds
