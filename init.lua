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
require("tmpi-debug").setup()
require("config_parser").setup()
vim.keymap.set('n', '<leader>drr', function()
  local file = vim.fn.expand('%')
  local line = vim.fn.line('.')
  local cmd = string.format('b %s:%d', file, line)
  local handle = io.popen("tmux display-message -p '#S'")
  local tmux_session = handle:read("*a"):gsub("%s+", "")
  handle:close()

  -- Name of your tmux session, window, and pane (edit accordingly)
  local tmux_target1 = tmux_session .. ':0.1' -- session:window.pane
  local tmux_target2 = tmux_session .. ':0.2' -- session:window.pane

  -- Send the command using tmux
  local send_cmd = string.format("tmux send-keys -t %s '%s' C-m", tmux_target1, cmd)
  os.execute(send_cmd)
  send_cmd = string.format("tmux send-keys -t %s '%s' C-m", tmux_target2, cmd)
  os.execute(send_cmd)
end, { desc = "Set GDB breakpoint at current line" })

vim.keymap.set('n', '<leader>cl', function()
  vim.fn.setreg('+', vim.fn.expand('%') .. ':' .. vim.fn.line('.'))
end, { desc = "Copy filename:line to clipboard" })

require('work_journal').setup({
  -- Optional: customize settings
  journal_dir = vim.fn.expand('~/Documents/work-journal'),
  date_format = '%Y-%m-%d',
  file_extension = 'md',
  template = "# Work Journal: %date%\n\n## Tasks\n\n- [ ] \n\n## Notes\n\n",
})


vim.filetype.add({
  extension = {
    config = "json",
    asx = "asx",
  },
})

vim.opt.runtimepath:append("/home/gaurav/.config/nvim/git-compare.nvim")
require("git-compare").setup()

vim.keymap.set("n", "<leader>ma", "mA", { desc = "Set global mark A" })
vim.keymap.set("n", "<leader>mb", "mB", { desc = "Set global mark B" })
vim.keymap.set("n", "<leader>mc", "mC", { desc = "Set global mark C" })

vim.keymap.set("n", "<leader>ja", "`A", { desc = "Jump to global mark A" })
vim.keymap.set("n", "<leader>jb", "`B", { desc = "Jump to global mark B" })
vim.keymap.set("n", "<leader>jc", "`C", { desc = "Jump to global mark C" })
