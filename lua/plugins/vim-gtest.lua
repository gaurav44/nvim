return {
  'alepez/vim-gtest',

  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local sorters = require("telescope.sorters")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- Variables
    local working_dir = nil

    -- Set GTest command
    local function set_gtest_command_as_absolute(gtest_command)
      local absolute_path = vim.fn.fnamemodify(gtest_command, ':p')
      if not vim.fn.filereadable(absolute_path) then
        absolute_path = vim.fn.fnamemodify(vim.fn.getcwd() .. '/' .. gtest_command, ':p')
      end

      vim.g['gtest#gtest_command'] = absolute_path
      print("GTest executable path set to: " .. absolute_path)
    end

    -- Find GTest Executable in Background
    local function find_gtest_executable()
      local base_dir = "build/test/"
      local executables = {
        base_dir .. "*_test",
        base_dir .. "*_tests"
      }

      local found_executable = false
      for _, pattern in ipairs(executables) do
        for _, file in ipairs(vim.fn.glob(pattern, true, true)) do
          if vim.fn.filereadable(file) then
            print("Found GTest executable at: " .. file)
            -- vim.g['gtest#gtest_command'] = file
            set_gtest_command_as_absolute(file)
            found_executable = true
            break
          end
        end
        if found_executable then break end
      end

      if not found_executable then
        print("GTest executable not found in " .. base_dir .. ". Please set it using :GTestSetCommand.")
      end
    end

    -- Initialize GTest executable discovery in background
    vim.defer_fn(find_gtest_executable, 0)

    vim.api.nvim_create_user_command('GTestSetCommand', function()
      vim.ui.input({
        prompt = "Enter GTest command: ",
        completion = "file",
      }, function(gtest_command)
        if gtest_command then
          set_gtest_command_as_absolute(gtest_command)
        else
          print("No command provided!")
        end
      end)
    end, {})

    -- Set Working Directory
    local function set_gtest_working_dir()
      vim.ui.input({
        prompt = 'Enter test working directory: ',
        completion = 'dir',
        default = vim.fn.expand('%:p:h')
      }, function(directory)
        if directory and directory ~= '' then
          working_dir = directory
          print("Working directory set to: " .. working_dir)
        else
          print("No directory provided!")
        end
      end)
    end

    vim.api.nvim_create_user_command('GTestSetWorkingDir', set_gtest_working_dir, {})

    -- Run GTest in ToggleTerm
    local function run_gtest_from_stored_dir(test_case)
      if not working_dir then
        print("Working directory is not set!")
        return
      end
      if not vim.g["gtest#gtest_command"] then
        print("GTest executable is not set!")
        return
      end

      local old_dir = vim.fn.getcwd()
      vim.cmd('lcd ' .. working_dir)

      local gtest_cmd = vim.g["gtest#gtest_command"]
      if test_case then
        gtest_cmd = gtest_cmd .. " --gtest_filter=" .. test_case
      end

      print("Running GTest from working directory: " .. working_dir)
      print("Command: " .. gtest_cmd)

      local gtest_term = Terminal:new({
        cmd = gtest_cmd,
        direction = "float",
        close_on_exit = false,
      })
      gtest_term:toggle()

      vim.cmd('lcd ' .. old_dir)
    end

    vim.api.nvim_create_user_command('GTestRunFromDir', run_gtest_from_stored_dir, {})

    -- Test Case Selection (Telescope)
    local function get_gtest_cases()
      local gtest_executable = vim.g["gtest#gtest_command"]
      if not gtest_executable or gtest_executable == "" then
        print("GTest executable is not set. Use :GTestSetCommand to set it.")
        return {}
      end

      local handle = io.popen(gtest_executable .. " --gtest_list_tests")
      if not handle then
        print("Failed to run GTest executable.")
        return {}
      end

      local output = handle:read("*a")
      handle:close()

      local test_cases = {}
      local current_suite = nil
      for line in output:gmatch("[^\r\n]+") do
        if line:match("%s") then
          local test_case = line:match("^%s*(%S+)")
          if current_suite and test_case then
            table.insert(test_cases, current_suite .. test_case)
          end
        else
          current_suite = line
        end
      end

      return test_cases
    end

    -- Fuzzy Select Test Case
    local function fuzzy_select_gtest_case()
      local test_cases = get_gtest_cases()

      if #test_cases == 0 then
        print("No test cases found. Ensure GTestCmd is set and executable.")
        return
      end

      pickers.new({}, {
        prompt_title = "Select GTest Case",
        finder = finders.new_table({ results = test_cases }),
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              run_gtest_from_stored_dir(selection[1])
            end
          end)
          return true
        end,
      }):find()
    end

    -- Keybindings
    vim.keymap.set('n', '<leader>tc', fuzzy_select_gtest_case, { desc = "Select GTest Case" })
    vim.keymap.set('n', '<leader>tr', run_gtest_from_stored_dir, { desc = "Run GTest from stored directory" })
    vim.keymap.set('n', '<leader>td', set_gtest_working_dir, { desc = "Set GTest Working Directory" })
  end
}
