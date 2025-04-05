local M = {}

M.gtest_executable = nil
M.test_cases = nil

local Terminal = require("toggleterm.terminal").Terminal
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.find_gtest_executable()
  local base_dir = "build/test/"
  local patterns = { "*_test", "*_tests" }

  for _, pattern in ipairs(patterns) do
    for _, file in ipairs(vim.fn.glob(base_dir .. pattern, true, true)) do
      if vim.fn.filereadable(file) then
        M.gtest_executable = vim.fn.fnamemodify(file, ":p")
        print("GTest executable found: " .. M.gtest_executable)
        return
      end
    end
  end

  print("No GTest executable found in " .. base_dir)
end

function M.run_test(test_filter)
  if not M.gtest_executable then
    print("No test executable detected. Run gtest.detect_executable() first.")
    return
  end

  local original_dir = vim.fn.getcwd() -- Store the original working directory
  local test_dir = "test/aspherix-letters/data"
  local cmd = M.gtest_executable

  if test_filter then
    cmd = cmd .. " --gtest_filter=" .. test_filter
    
    -- Check if a shell pane exists
    local check_pane = io.popen(
    'tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
    local pane_exists = check_pane:read("*a")
    check_pane:close()

    if pane_exists:match("exists") then
      -- Send command to the existing shell pane with cd back to original directory
      vim.cmd(string.format(
        'silent !tmux send-keys -t "{last}" "cd %s && %s && cd %s" Enter && cd -', 
        test_dir, 
        cmd, 
        vim.fn.shellescape(original_dir)
      ))
    else
      -- Create a new split and run the command with cd back to original directory
      vim.cmd(string.format(
        'silent !tmux split-window -h "cd %s && %s && cd %s; exec $SHELL"', 
        test_dir, 
        cmd, 
        vim.fn.shellescape(original_dir)
      ))
    end
  else
    print("No test_filter set!!!!")
    return
  end

  print("Running test: " .. cmd)
end

function M.run_all_tests_except_debug()
  if not M.gtest_executable then
    print("No test executable detected. Run gtest.detect_executable() first.")
    return
  end

  local original_dir = vim.fn.getcwd() -- Store the original working directory
  local test_dir = "test/aspherix-letters/data"
  
  -- Get all test cases
  local handle = io.popen(M.gtest_executable .. " --gtest_list_tests")
  if not handle then
    print("Failed to run GTest executable.")
    return
  end

  local output = handle:read("*a")
  handle:close()

  local test_cases = {}
  local current_suite = nil
  for line in output:gmatch("[^\r\n]+") do
    if line:match("%s") then
      local test_case = line:match("^%s*(%S+)")
      if current_suite and test_case then
        local full_test_name = current_suite .. test_case
        -- Exclude tests with 'debug' (case-insensitive)
        if not full_test_name:lower():match("debug") then
          table.insert(test_cases, full_test_name)
        end
      end
    else
      current_suite = line
    end
  end

  -- Create filter string by joining non-debug test cases
  local test_filter = table.concat(test_cases, ":")
  local cmd = M.gtest_executable .. " --gtest_filter=" .. test_filter

  -- Check if a shell pane exists
  local check_pane = io.popen(
  'tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
  local pane_exists = check_pane:read("*a")
  check_pane:close()

  if pane_exists:match("exists") then
    -- Send command to the existing shell pane with cd back to original directory
    vim.cmd(string.format(
      'silent !tmux send-keys -t "{last}" "cd %s && %s && cd %s" Enter && cd -', 
      test_dir, 
      cmd, 
      vim.fn.shellescape(original_dir)
    ))
  else
    -- Create a new split and run the command with cd back to original directory
    vim.cmd(string.format(
      'silent !tmux split-window -h "cd %s && %s && cd %s; exec $SHELL"', 
      test_dir, 
      cmd, 
      vim.fn.shellescape(original_dir)
    ))
  end

  print("Running all tests except debug tests")
  print("Total non-debug test cases: " .. #test_cases)
end

function M.run_only_debug_tests()
  if not M.gtest_executable then
    print("No test executable detected. Run gtest.detect_executable() first.")
    return
  end

  local original_dir = vim.fn.getcwd() -- Store the original working directory
  local test_dir = "test/aspherix-letters/data"
  
  -- Get all test cases
  local handle = io.popen(M.gtest_executable .. " --gtest_list_tests")
  if not handle then
    print("Failed to run GTest executable.")
    return
  end

  local output = handle:read("*a")
  handle:close()

  local debug_test_cases = {}
  local current_suite = nil
  for line in output:gmatch("[^\r\n]+") do
    if line:match("%s") then
      local test_case = line:match("^%s*(%S+)")
      if current_suite and test_case then
        local full_test_name = current_suite .. test_case
        -- Include only tests with 'debug' (case-insensitive)
        if full_test_name:lower():match("debug") then
          table.insert(debug_test_cases, full_test_name)
        end
      end
    else
      current_suite = line
    end
  end

  -- If no debug tests found, print a message
  if #debug_test_cases == 0 then
    print("No debug tests found.")
    return
  end

  -- Create filter string by joining debug test cases
  local test_filter = table.concat(debug_test_cases, ":")
  local cmd = M.gtest_executable .. " --gtest_filter=" .. test_filter

  -- Check if a shell pane exists
  local check_pane = io.popen(
  'tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
  local pane_exists = check_pane:read("*a")
  check_pane:close()

  if pane_exists:match("exists") then
    -- Send command to the existing shell pane with cd back to original directory
    vim.cmd(string.format(
      'silent !tmux send-keys -t "{last}" "cd %s && %s && cd %s" Enter && cd -', 
      test_dir, 
      cmd, 
      vim.fn.shellescape(original_dir)
    ))
  else
    -- Create a new split and run the command with cd back to original directory
    vim.cmd(string.format(
      'silent !tmux split-window -h "cd %s && %s && cd %s; exec $SHELL"', 
      test_dir, 
      cmd, 
      vim.fn.shellescape(original_dir)
    ))
  end

  print("Running only debug tests")
  print("Total debug test cases: " .. #debug_test_cases)
end

-- Test Case Selection (Telescope)
local function get_gtest_cases()
  if not M.gtest_executable then
    print("GTest executable is not set. Use :GTestSetCommand to set it.")
    return {}
  end

  local handle = io.popen(M.gtest_executable .. " --gtest_list_tests")
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
function M.fuzzy_select_gtest_case()
  local test_cases = get_gtest_cases()
  print("Fuzzy select GTest case called.") -- Debug statement

  if #test_cases == 0 then
    print("No test cases found. Ensure GTestCmd is set and executable.")
    return
  end
  print("Fuzzy select GTest case called.") -- Debug statement

  pickers.new({}, {
    prompt_title = "Select GTest Case",
    finder = finders.new_table({ results = test_cases }),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection and selection.value then              -- Access the correct value
          print("Selected test case: " .. selection.value) -- Debug statement
          M.run_test(selection[1])                         -- Pass the selected value
        else
          print("No test case selected.")
        end
      end)
      return true
    end,
  }):find()
end

function M.setup()
  vim.api.nvim_create_user_command("GTestDetect", M.find_gtest_executable, {})
  vim.api.nvim_create_user_command("GTestRun", M.run_test, {})
  vim.api.nvim_create_user_command('GTestFuzzyFind', M.fuzzy_select_gtest_case, {})
  vim.api.nvim_create_user_command('GTestRunAllExceptDebug', M.run_all_tests_except_debug, {})
  vim.api.nvim_create_user_command('GTestRunOnlyDebug', M.run_only_debug_tests, {})
  -- Keybindings (commented out as they're now in which-key.nvim)
  -- vim.keymap.set('n', '<leader>tc', ":GTestFuzzyFind<CR>", { desc = "Select GTest Case" })
  -- vim.keymap.set('n', '<leader>ta', ":GTestRunAllExceptDebug<CR>", { desc = "Run All Tests Except Debug" })
  -- vim.keymap.set('n', '<leader>td', ":GTestRunOnlyDebug<CR>", { desc = "Run Only Debug Tests" })
end

return M
