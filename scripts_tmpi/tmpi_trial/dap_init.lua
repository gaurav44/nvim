-- Check if dap module is available
local has_dap, dap = pcall(require, 'dap')
if not has_dap then
  print("Error: nvim-dap is not installed. Please install it with your plugin manager.")
  print("For example with packer.nvim: use {'mfussenegger/nvim-dap'}")
  return
end

-- Configure nvim-dap for C/C++ debugging
dap.configurations.cpp = {
  {
    name = "MPI Process Attach",
    type = "cppdbg",
    request = "attach",
    processId = 2725216,
    program = "/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi",
    cwd = "/home/gaurav/Desktop/trials/tmpi_trial",
    stopOnEntry = true,
    setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "Enable pretty printing",
        ignoreFailures = true
      },
    }
  },
}

-- Also add the same configuration for C files
dap.configurations.c = dap.configurations.cpp

-- Start the debugging session automatically
vim.cmd('echo "Attaching debugger to MPI process ' .. 2725216 .. '"')
vim.defer_fn(function() 
  if has_dap then
    require('dap').continue()
  end
end, 1000)
