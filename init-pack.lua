require("vim-options")

vim.pack.add({
  {src = "https://github.com/Mofiqul/vscode.nvim"},
  {src = "http://github.com/ibhagwan/fzf-lua"},
  {src = "https://github.com/windwp/nvim-autopairs"},
  {src = "https://github.com/christoomey/vim-tmux-navigator"},
  {src = "https://github.com/MunifTanjim/nui.nvim"},
  {src = "https://github.com/folke/noice.nvim"},
})

require("vscode").setup({
  transparent = false,
  italic_comments = true,
  disable_nvimtree_bg = true,
})

vim.cmd.colorscheme("vscode")

-- Bundled syntax highlighting: no downloaded Tree-sitter parsers required.
-- Clangd adds semantic highlighting when attached to C/C++ buffers.
vim.cmd("syntax enable")

require("nvim-autopairs").setup({})

-- Keep the navigator's default mappings, including its tmux integration.
-- Explicit normal-mode mappings also provide descriptions in the key picker.
vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { silent = true, desc = "Navigate left" })
vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { silent = true, desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { silent = true, desc = "Navigate up" })
vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { silent = true, desc = "Navigate right" })

require("noice").setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    format = {
      cmdline = { pattern = "^:", icon = "󱐌 :", lang = "vim" },
      help = { pattern = "^:%s*he?l?p?%s+", icon = " 󰮦 :" },
      search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = "/", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = " $ :", lang = "bash" },
      lua = {
        pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
        icon = "  :",
        lang = "lua",
      },
      input = { view = "cmdline_input", icon = " 󰥻 :" },
    },
  },
  views = {
    popupmenu = {
      relative = "editor",
      position = { row = 8, col = "50%" },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
    mini = {
      size = { width = "auto", height = "auto", max_height = 15 },
      position = { row = -2, col = "100%" },
    },
  },
  lsp = {
    progress = { enabled = true },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
    signature = {
      enabled = true,
      auto_open = { enabled = false },
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
          { find = "%d fewer lines" },
          { find = "%d more lines" },
        },
      },
      opts = { skip = true },
    },
  },
  messages = { enabled = false },
  popupmenu = { enabled = true },
})

-- One status line across the bottom, including when using splits.
vim.opt.laststatus = 3
vim.opt.statusline = table.concat({
  " %{toupper(mode())} ",
  "%<%f %m%r",
  "%=",
  "%y ",
  "%l:%c ",
  "%p%% ",
})

local fzf = require("fzf-lua")
fzf.setup({
	previewers = {
		builtin = {
			syntax = true,
			treesitter = { enabled = false },
		},
	},
	winopts = {
		treesitter = { enabled = false },
		height = 0.80,
		width = 0.85,
		row = 0.50,
		col = 0.50,
		border = "rounded",
		preview = {
			hidden = false,
			layout = "horizontal",
			horizontal = "right:55%",
			vertical = "down:50%",
		},
	},
})
fzf.register_ui_select()

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files", })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find open buffers", })
vim.keymap.set("n", "<leader>fc", fzf.blines, { desc = "Fuzzy search current buffer", })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Search project text", })
vim.keymap.set("n", "<leader>fm", fzf.marks, { desc = "Find marks", })
vim.keymap.set("n", "<leader>fs", fzf.live_grep, { desc = "Search text in current directory" })
vim.keymap.set("n", "<leader>fM", fzf.marks, { desc = "Fuzzy find marks" })
vim.keymap.set("n", "<leader>?", fzf.keymaps, { desc = "Search key mappings" })
vim.keymap.set("n", "<leader>nh", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

vim.lsp.config("clangd", {
	cmd = { "clangd", "--clang-tidy", "--enable-config" },
	filetypes = { "c", "cpp" },
	root_markers = {
		".clangd",
		"compile_commands.json",
		"compile_flags.txt",
		".git",
	},
})

vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("NativeCompletion", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, {
        autotrigger = true,
      })

      vim.keymap.set("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, {
        buffer = event.buf,
        desc = "Complete from language server",
      })
    end
  end,
})

vim.lsp.enable("clangd")

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition", })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Find references", })
vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, { desc = "Code actions", })
vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "<leader>gK", vim.lsp.buf.hover, { desc = "Show symbol documentation" })

vim.keymap.set("n", "<leader>gs", function()
  vim.lsp.buf.document_symbol()
end, { desc = "List document symbols" })

vim.keymap.set("n", "<leader>gS", function()
  vim.lsp.buf.workspace_symbol()
end, { desc = "Search workspace symbols" })

vim.keymap.set("n", "<leader>gf", function()
  vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
end, {
  desc = "Format buffer",
})

vim.keymap.set("n", "<leader>xw", function()
  vim.diagnostic.setqflist()
end, { desc = "List all known diagnostics" })

vim.keymap.set("n", "<leader>xd", function()
  vim.diagnostic.setloclist()
end, { desc = "List current buffer diagnostics" })

vim.keymap.set("n", "<leader>xq", "<Cmd>copen<CR>", { desc = "Open quickfix list" })
vim.keymap.set("n", "<leader>xl", "<Cmd>lopen<CR>", { desc = "Open location list" })

vim.keymap.set("n", "<leader>gn", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "<leader>gp", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })

vim.keymap.set("n", "<leader>gk", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostic details" })
