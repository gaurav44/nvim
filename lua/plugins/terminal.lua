return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 10,
				open_mapping = true,
				hide_numbers = true,
				shade_filetypes = {},
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
			})
			local opts = { buffer = 0 }
			vim.keymap.set("t", "<esc>",[[<C-\><C-n>]], { noremap = true})
			vim.keymap.set("t", "jk", [[<C-\><C-n>]], { noremap = true })
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { noremap = true })
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { noremap = true })
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { noremap = true})
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { noremap = true})
			vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], { noremap = true})
			vim.keymap.set("n", "<C-t>", ":ToggleTerm<CR>", { noremap = true })
		end,
	},
}
