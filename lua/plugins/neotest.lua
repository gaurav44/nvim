return {
  {
    'nvim-neotest/nvim-nio'
  },
  {
    'antoinemadec/FixCursorHold.nvim'
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'alfaix/neotest-gtest'
    },
    config = function ()
      adapters = {
        require("neotest-gtest").setup({})
      }
    end
  },
}
