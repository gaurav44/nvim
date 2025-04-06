local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {}

require("vim-options")
require("lazy").setup("plugins")
require("cmake-mappings").setup()
require("vim-gtest").setup()
--vim.api.nvim_set_keymap('n', '<Leader>rr', ':luafile $MYVIMRC<CR>', { noremap = true, silent = true })




