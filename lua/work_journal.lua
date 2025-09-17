-- Work Journal plugin for Neovim

local M = {}

-- Configuration with defaults
M.config = {
  -- Directory to store journal entries
  journal_dir = vim.fn.expand('~/work-journal'),
  -- Format for date in filename (YYYY-MM-DD)
  date_format = '%Y-%m-%d',
  -- File extension for journal entries
  file_extension = 'md',
  -- Template for new journal entries
  template = "# Work Journal: %date%\n\n## Tasks\n\n- [ ] \n\n## Notes\n\n",
}

-- Initialize the journal
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    for k, v in pairs(opts) do
      M.config[k] = v
    end
  end
  
  -- Create journal directory if it doesn't exist
  if vim.fn.isdirectory(M.config.journal_dir) == 0 then
    vim.fn.mkdir(M.config.journal_dir, 'p')
  end
  
  -- Create command to open journal
  vim.api.nvim_create_user_command('WorkJournal', function()
    M.open_journal()
  end, {})
  
  -- Set up keybinding to open journal (default: <Leader>wj)
  vim.keymap.set('n', '<Leader>wj', function() 
    M.open_journal() 
  end, { noremap = true, silent = true, desc = "Open work journal" })
end

-- Get today's date formatted according to config
function M.get_today_date()
  return os.date(M.config.date_format)
end

-- Get the filename for today's journal
function M.get_journal_filename()
  local date = M.get_today_date()
  return M.config.journal_dir .. '/' .. date .. '.' .. M.config.file_extension
end

-- Create a new journal entry with template
function M.create_journal_entry(filename)
  local file = io.open(filename, 'w')
  if not file then
    vim.notify("Failed to create journal file: " .. filename, vim.log.levels.ERROR)
    return false
  end
  
  local template = M.config.template:gsub('%%date%%', M.get_today_date())
  file:write(template)
  file:close()
  return true
end

-- Open today's journal entry
function M.open_journal()
  local filename = M.get_journal_filename()
  
  -- Create the file with template if it doesn't exist
  if vim.fn.filereadable(filename) == 0 then
    if not M.create_journal_entry(filename) then
      return
    end
  end
  
  -- Open the journal file
  vim.cmd('edit ' .. filename)
  
  -- Position cursor at the first empty task
  vim.cmd([[normal! /\[ \]$]])
  vim.cmd([[normal! l]])
end

return M