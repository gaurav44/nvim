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
    end,
  },
}
