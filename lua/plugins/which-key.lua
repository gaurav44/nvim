return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			local wk = require("which-key")

			-- Setup which-key
			wk.setup({
				plugins = {
					marks = true,
					registers = true,
					spelling = {
						enabled = true,
						suggestions = 20,
					},
					presets = {
						operators = true,
						motions = true,
						text_objects = true,
						windows = true,
						nav = true,
						z = true,
						g = true,
					},
				},
				replace = {
					key = {
						function(key)
							return require("which-key.view").format(key)
						end,
						-- { "<Space>", "SPC" },
					},
					desc = {
						{ "<Plug>%(?(.*)%)?", "%1" },
						{ "^%+", "" },
						{ "<[cC]md>", "" },
						{ "<[cC][rR]", "" },
						{ "<[sS]ilent>", "" },
						{ "^lua%s+", "" },
						{ "^call%s+", "" },
						{ "^:%s*", "" },
					},
				},
				icons = {
					breadcrumb = "»",
					separator = "",
					group = "+",
				},
				win = {
					-- don't allow the popup to overlap with the cursor
					no_overlap = true,
					-- width = 1,
					-- height = { min = 4, max = 25 },
					-- col = 0,
					-- row = math.huge,
					-- border = "none",
					padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
					title = true,
					title_pos = "center",
					zindex = 1000,
					-- Additional vim.wo and vim.bo options
					bo = {},
					wo = {
						winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
					},
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
				},
				filter = function(mapping)
					return true
				end,
				show_help = true,
				triggers = {
					{ "<auto>", mode = "nxso" },
				},
				--trigger_no_wait = true,
				delay = 0,
				disable = {},
				side_labels = true,
			})

			wk.add({
				-- Telescope mappings
				{ "<leader>f", group = "🔍 Telescope" },
				{
					"<leader>ff",
					function()
						require("telescope.builtin").find_files()
					end,
					desc = "🔍 Find Buffers",
				},
				{
					"<leader>fg",
					function()
						require("telescope.builtin").live_grep()
					end,
					desc = "📄 Find Files",
				},
				{
					"<leader>fs",
					function()
						require("telescope.builtin").grep_string()
					end,
					desc = "🔎 Live Grep",
				},
				{
					"<leader>fb",
					function()
						require("telescope.builtin").buffers()
					end,
					desc = "📝 Grep String",
				},
				{
					"<leader>fc",
					function()
						require("telescope.builtin").current_buffer_fuzzy_find()
					end,
					desc = "🔍 Search in Current Buffer",
				},

				-- LSP mappings
				{ "<leader>g", group = "🛠️ LSP" },
				{
					"<leader>gd",
					function()
						vim.lsp.buf.definition()
					end,
					desc = "📍 Go to Definition",
				},
				{
					"<leader>gt",
					function()
						vim.lsp.buf.type_definition()
					end,
					desc = "🏷️ Go to Type Definition",
				},
				{
					"<leader>gD",
					function()
						vim.lsp.buf.declaration()
					end,
					desc = "📜 Go to Declaration",
				},
				{
					"<leader>gr",
					function()
						vim.lsp.buf.references()
					end,
					desc = "🔗 Find References",
				},
				{
					"<leader>gk",
					function()
						vim.diagnostic.open_float()
					end,
					desc = "🔍 Show Diagnostic in Float",
				},
				{
					"<leader>gs",
					function()
						require("telescope.builtin").lsp_document_symbols()
					end,
					desc = "🔠 Document Symbols",
				},
				{
					"<leader>ga",
					function()
						vim.lsp.buf.code_action()
					end,
					desc = "💡 Code Action",
				},
				{
					"<leader>gf",
					function()
						vim.lsp.buf.format()
					end,
					desc = "✨ Format Document",
				},
				{
					"<leader>gK",
					function()
						vim.lsp.buf.hover()
					end,
					desc = "📖 Show Hover",
				},
				{
					"<leader>gp",
					function()
						vim.diagnostic.goto_prev()
					end,
					desc = "⬆️ Previous Diagnostic",
				},
				{
					"<leader>gn",
					function()
						vim.diagnostic.goto_next()
					end,
					desc = "⬇️ Next Diagnostic",
				},

				-- Debug
				{ "<leader>d", group = "🐛 Debug" },
				{
					"<leader>db",
					function()
						require("dap").toggle_breakpoint()
					end,
					desc = "🔴 Toggle Breakpoint",
				},
				{
					"<leader>dc",
					function()
						require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
					end,
					desc = "❓ Conditional Breakpoint",
				},
				{
					"<leader>dr",
					function()
						require("dap").repl.open()
					end,
					desc = "📟 Open REPL",
				},
				{
					"<leader>du",
					function()
						require("dapui").toggle()
					end,
					desc = "🖥️ Toggle UI",
				},
				{
					"<leader>dg",
					function()
						require("dap").continue()
					end,
					desc = "▶️ Start/Continue Debug",
				},
				{
					"<leader>ds",
					function()
						require("dap").step_over()
					end,
					desc = "⏭️ Step Over",
				},
				{
					"<leader>di",
					function()
						require("dap").step_into()
					end,
					desc = "⤵️ Step Into",
				},
				{
					"<leader>do",
					function()
						require("dap").step_out()
					end,
					desc = "⤴️ Step Out",
				},
				{
					"<leader>dq",
					function()
						require("dap").close()
					end,
					desc = "❌ Quit Debug",
				},
				{
					"<leader>dt",
					function()
						require("dap").terminate()
					end,
					desc = "🛑 Terminate Debug",
				},

				-- Git mappings
				{ "<leader>G", group = "🔄 Git" },
				{ "<leader>Gg", "<cmd>LazyGit<CR>", desc = "🧩 LazyGit" },
				{ "<leader>Gd", "<cmd>DiffviewOpen<CR>", desc = "📊 Diff View" },
				{ "<leader>Gh", "<cmd>DiffviewFileHistory<CR>", desc = "📜 File History" },
				{ "<leader>Gc", "<cmd>DiffviewClose<CR>", desc = "❌ Close Diff View" },
				{
					"<leader>Gs",
					function()
						require("gitsigns").stage_hunk()
					end,
					desc = "➕ Stage Hunk",
				},
				{
					"<leader>Gr",
					function()
						require("gitsigns").reset_hunk()
					end,
					desc = "↩️ Reset Hunk",
				},
				{
					"<leader>GS",
					function()
						require("gitsigns").stage_buffer()
					end,
					desc = "📋 Stage Buffer",
				},
				{
					"<leader>Gu",
					function()
						require("gitsigns").undo_stage_hunk()
					end,
					desc = "↪️ Undo Stage Hunk",
				},
				{
					"<leader>GR",
					function()
						require("gitsigns").reset_buffer()
					end,
					desc = "🔄 Reset Buffer",
				},
				{
					"<leader>Gp",
					function()
						require("gitsigns").preview_hunk()
					end,
					desc = "👁️ Preview Hunk",
				},
				{
					"<leader>Gb",
					function()
						require("gitsigns").blame_line({ full = true })
					end,
					desc = "ℹ️ Blame Line",
				},
				{
					"<leader>GB",
					function()
						require("gitsigns").toggle_current_line_blame()
					end,
					desc = "👤 Toggle Line Blame",
				},
				{
					"<leader>Gn",
					function()
						require("gitsigns").next_hunk()
					end,
					desc = "⬇️ Next Hunk",
				},
				{
					"<leader>GN",
					function()
						require("gitsigns").prev_hunk()
					end,
					desc = "⬆️ Prev Hunk",
				},

				--Buffers
				{
					"<leader>b",
					group = "📑 Buffers",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},

				-- Outline
				{ "<leader>o", "<cmd>Outline<cr>", desc = "📋 Toggle Outline" },

				-- CMake mappings
				{ "<leader>c", group = "🛠️ CMake/Build" },
	
        -- GTest mappings
				{ "<leader>t", group = "🧪 GTest" },
				{ "<leader>tc", "<cmd>GTestFuzzyFind<CR>", desc = "🔍 Fuzzy select GTest Case" },
				{ "<leader>ta", "<cmd>GTestRunAllExceptDebug<CR>", desc = "▶️ Run All Tests Except Debug" },
				{ "<leader>td", "<cmd>GTestRunOnlyDebug<CR>", desc = "🔬 Run Only Debug Tests" },
			})
		end,
	},
}
