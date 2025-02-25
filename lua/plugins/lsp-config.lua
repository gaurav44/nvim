return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "cmake" },  -- Add "cmake" here
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {"clangd", "--clang-tidy", "--enable-config"},
      })

      -- Add CMake language server configuration
      lspconfig.cmake.setup({
        capabilities = capabilities,
      })

      vim.diagnostic.config({
        virtual_text = false,
      })

      -- Show line diagnostics automatically in hover window
      -- vim.o.updatetime = 5
      -- vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

      vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition, {})
      vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {})
      vim.keymap.set('n', '[d', vim.diagnostic.goto_next, {})
      vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, {})
      vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end,
  },
}
