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
local mpi_debug = require("mpi_debug")

-- Create a command to make it easier to use
-- Add this to your init.lua or where you define commands
vim.api.nvim_create_user_command("MPIDebug", function(opts)
  local args = vim.split(opts.args, " ")
  local pid = tonumber(args[1])
  local program = args[2]
  local cwd = args[3]
  
  if not pid then
    vim.notify("Please provide a valid PID", vim.log.levels.ERROR)
    return
  end
  
  require("mpi_debug").attach_to_mpi_process(pid, program, cwd)
end, { nargs = "*", desc = "Attach debugger to MPI process with optional program path and working directory" })
--vim.api.nvim_set_keymap('n', '<Leader>rr', ':luafile $MYVIMRC<CR>', { noremap = true, silent = true })




