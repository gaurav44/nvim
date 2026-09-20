return {
  {
    "hrsh7th/cmp-nvim-lsp"
  },
  {
  	"L3MON4D3/LuaSnip",
  	dependencies = {
  		"saadparwaiz1/cmp_luasnip",
  		"rafamadriz/friendly-snippets",
  	},
	config = function()
		local luasnip = require("luasnip")

		luasnip.add_snippets("cpp", require("snippets"))

		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			luasnip.expand_or_jump()
		end, { silent = true, desc = "Expand or jump forward in snippet" })

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			luasnip.jump(-1)
		end, { silent = true, desc = "Jump backward in snippet" })
	end,
  },
  {
  	"hrsh7th/nvim-cmp",
  	config = function()
  		local cmp = require("cmp")
  		require("luasnip.loaders.from_vscode").lazy_load()
  		cmp.setup({
  			snippet = {
  				expand = function(args)
  					require("luasnip").lsp_expand(args.body)
  				end,
  			},
  			window = {
  				completion = cmp.config.window.bordered(),
  				documentation = cmp.config.window.bordered(),
  			},
  			mapping = cmp.mapping.preset.insert({
  				["<C-b>"] = cmp.mapping.scroll_docs(-4),
  				["<C-f>"] = cmp.mapping.scroll_docs(4),
  				["<C-Space>"] = cmp.mapping.complete(),
  				["<C-e>"] = cmp.mapping.abort(),
  				["<CR>"] = cmp.mapping.confirm({ select = true }),
  			}),
  			sources = cmp.config.sources({
  				{ name = "nvim_lsp" },
  				{ name = "luasnip" },
  			}, {
  				{ name = "buffer" },
  			}),
  		})
  	end,
  },
}
