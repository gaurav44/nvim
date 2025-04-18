local M = {}

local function create_dirs(preset)
  if preset and preset:lower():match("debug") then
    os.execute("mkdir -p build-debug install-debug")
    return "build-debug"
  else
    os.execute("mkdir -p build install")
    return "build"
  end
end

local function send_to_tmux(cmd)
  vim.cmd('silent !tmux select-window -t terminal && tmux send-keys "' .. cmd .. '" Enter')
end

function M.select_preset()
  local handle = io.popen("cmake --list-presets")
  local result = handle:read("*a")
  handle:close()

  if not result or result == "" then
    print("No presets found.")
    return
  end

  local presets = {}
  for line in result:gmatch("[^\r\n]+") do
    if not line:match("^Available") then
      table.insert(presets, line)
    end
  end

  vim.ui.select(presets, { prompt = "Select CMake Preset" }, function(choice)
    if choice then
      create_dirs(choice)
      send_to_tmux("cmake --preset " .. choice)
    end
  end)
end

function M.build_release()
  create_dirs()
  send_to_tmux("cmake --build build --parallel 36")
end

function M.build_debug()
  create_dirs("debug")
  send_to_tmux("cmake --build build-debug --parallel 36")
end

function M.setup()
  vim.keymap.set("n", "<leader>cm", M.select_preset, { noremap = true, silent = true, desc = 'Select CMake Preset' })
  vim.keymap.set("n", "<leader>cr", M.build_release, { noremap = true, silent = true, desc = 'Build Release' })
  vim.keymap.set("n", "<leader>cd", M.build_debug, { noremap = true, silent = true, desc = 'Build Debug' })
end

return M