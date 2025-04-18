local M = {}

M.config = {
  gtest_build_dir = "build/test/",
  test_run_dir = "test/aspherix-letters/data",
}
M.gtest_executable = nil

-- Telescope dependencies
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.configure()
  vim.ui.input({ prompt = "GTest build directory: ", default = M.config.gtest_build_dir }, function(input1)
    if input1 and input1 ~= "" then
      M.config.gtest_build_dir = input1
    end
    vim.ui.input({ prompt = "Test run directory: ", default = M.config.test_run_dir }, function(input2)
      if input2 and input2 ~= "" then
        M.config.test_run_dir = input2
      end
      print("GTest config updated:")
      print("  build dir: " .. M.config.gtest_build_dir)
      print("  run dir:   " .. M.config.test_run_dir)
    end)
  end)
end

-- Helper: Find GTest executable
function M.find_gtest_executable()
  local base_dir = M.config.gtest_build_dir
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

-- Helper: Run a shell command in tmux (reuse for all test runs)
local function run_in_tmux(test_dir, cmd, original_dir)
  local check_pane = io.popen(
    'tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
  local pane_exists = check_pane:read("*a")
  check_pane:close()
  if pane_exists:match("exists") then
    vim.cmd(string.format(
      'silent !tmux send-keys -t "{last}" "cd %s && %s && cd %s" Enter && cd -',
      test_dir, cmd, vim.fn.shellescape(original_dir)
    ))
  else
    vim.cmd(string.format(
      'silent !tmux split-window -h "cd %s && %s && cd %s; exec $SHELL"',
      test_dir, cmd, vim.fn.shellescape(original_dir)
    ))
  end
end

-- Helper: Get all test cases (optionally filter for debug/non-debug)
local function get_gtest_cases(filter)
  if not M.gtest_executable then
    print("GTest executable is not set. Use :GTestDetect to set it.")
    return {}
  end
  local handle = io.popen(M.gtest_executable .. " --gtest_list_tests")
  if not handle then
    print("Failed to run GTest executable.")
    return {}
  end
  local output = handle:read("*a")
  handle:close()
  local test_cases, current_suite = {}, nil
  for line in output:gmatch("[^\r\n]+") do
    if line:match("%s") then
      local test_case = line:match("^%s*(%S+)")
      if current_suite and test_case then
        local full = current_suite .. test_case
        if not filter or filter(full) then
          table.insert(test_cases, full)
        end
      end
    else
      current_suite = line
    end
  end
  return test_cases
end

-- Run a single test
function M.run_test(test_filter)
  if not M.gtest_executable then
    print("No test executable detected. Run :GTestDetect first.")
    return
  end
  if not test_filter then
    print("No test_filter set!")
    return
  end
  local original_dir = vim.fn.getcwd()
  local test_dir = M.config.test_run_dir
  local cmd = M.gtest_executable .. " --gtest_filter=" .. test_filter
  run_in_tmux(test_dir, cmd, original_dir)
  print("Running test: " .. cmd)
end

-- Run all tests except debug
function M.run_all_tests_except_debug()
  local cases = get_gtest_cases(function(name)
    return not name:lower():match("debug")
  end)
  if #cases == 0 then
    print("No non-debug test cases found.")
    return
  end
  local filter = table.concat(cases, ":")
  M.run_test(filter)
  print("Running all tests except debug tests")
  print("Total non-debug test cases: " .. #cases)
end

-- Run only debug tests
function M.run_only_debug_tests()
  local cases = get_gtest_cases(function(name)
    return name:lower():match("debug")
  end)
  if #cases == 0 then
    print("No debug tests found.")
    return
  end
  local filter = table.concat(cases, ":")
  M.run_test(filter)
  print("Running only debug tests")
  print("Total debug test cases: " .. #cases)
end

-- Telescope fuzzy select
function M.fuzzy_select_gtest_case()
  local test_cases = get_gtest_cases()
  if #test_cases == 0 then
    print("No test cases found. Ensure GTest executable is set.")
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
        if selection and selection.value then
          M.run_test(selection.value)
        else
          print("No test case selected.")
        end
      end)
      return true
    end,
  }):find()
end

-- Setup user commands
function M.setup()
  vim.api.nvim_create_user_command("GTestConfig", M.configure, {})
  vim.api.nvim_create_user_command("GTestDetect", M.find_gtest_executable, {})
  vim.api.nvim_create_user_command("GTestRun", function(opts)
    M.run_test(opts.args)
  end, { nargs = 1, desc = "Run a specific GTest by filter" })
  vim.api.nvim_create_user_command("GTestFuzzyFind", M.fuzzy_select_gtest_case, {})
  vim.api.nvim_create_user_command("GTestRunAllExceptDebug", M.run_all_tests_except_debug, {})
  vim.api.nvim_create_user_command("GTestRunOnlyDebug", M.run_only_debug_tests, {})
end

return M