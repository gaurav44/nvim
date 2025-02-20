return {
  'alepez/vim-gtest',

  config = function()
    -- Variable to store the working directory
    local working_dir = nil

    -- Function to print GTestCmd value
    local function gtest_debug()
      local executable_path = vim.g.GTestCmd
      print("GTest executable path: " .. (executable_path or "not set"))
    end

    -- Function to run gtest from the stored working directory
	local function run_gtest_from_stored_dir()
	    if working_dir then
		local old_dir = vim.fn.getcwd()  -- Save the current directory
		vim.cmd('lcd ' .. working_dir)  -- Change to the stored directory

		-- Print the command being executed (optional)
		print("Running GTest from working directory: " .. working_dir)

		-- Delegate to the existing GTestRun command
		vim.cmd('GTestRun')

		vim.cmd('lcd ' .. old_dir)  -- Change back to the original directory
	    else
		print("Working directory is not set!")
	    end
	end


    -- Function to set the working directory with autocompletion
    local function set_gtest_working_dir()
      vim.ui.input({
        prompt = 'Enter test working directory: ',
        completion = 'dir',  -- Enable directory completion
        default = vim.fn.expand('%:p:h')  -- Default to current file's directory
      }, function(directory)
        if directory and directory ~= '' then
          working_dir = directory  -- Store the directory
          print("Working directory set to: " .. working_dir)
        else
          print("No directory provided!")
        end
      end)
    end
    
    -- Function to set the GTest command as an absolute path
    local function set_gtest_command_as_absolute(gtest_command)
    	local current_dir = vim.fn.getcwd()  -- Get the current working directory
    	local absolute_path = vim.fn.fnamemodify(gtest_command, ':p')  -- Convert to absolute path
    	print("Current directory: " .. current_dir)
	print("Absolute path: " .. absolute_path)

    	-- Check if the command is relative and modify it if necessary
    	if not vim.fn.filereadable(absolute_path) then
        	absolute_path = vim.fn.fnamemodify(current_dir .. '/' .. gtest_command, ':p')  -- Create absolute path
    	end

    	vim.g['gtest#gtest_command'] = absolute_path  -- Set the absolute path
    	print("GTest executable path set to: " .. absolute_path)
    end

    -- Example usage: set the command and convert it
    vim.api.nvim_create_user_command('GTestSetCommand', function()
    vim.ui.input({
        prompt = "Enter GTest command: ",
        completion = "file",  -- Enable file path completion
    }, function(gtest_command)
        if gtest_command then
            set_gtest_command_as_absolute(gtest_command)
        else
            print("No command provided!")
        end
       end)
     end, {})

    -- Create user commands for setting the working directory and running gtests
    vim.api.nvim_create_user_command('GTestSetWorkingDir', set_gtest_working_dir, {})
    vim.api.nvim_create_user_command('GTestRunFromDir', run_gtest_from_stored_dir, {})
    vim.api.nvim_create_user_command('GTestDebug', gtest_debug, {})  -- Add GTestDebug command
  end
}

