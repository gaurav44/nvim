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
        ensure_installed = { "lua_ls", "clangd" },
        automatic_enable = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.offsetEncoding = { "utf-8" }

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
      })
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = { "clangd", "--clang-tidy", "--enable-config" },
      })
      vim.lsp.config("cmake", {
        capabilities = capabilities,
      })

      vim.lsp.enable({ "lua_ls", "clangd", "cmake" })

      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  },
}
