return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local treesitter = require("nvim-treesitter")
    local languages = {
      "bash",
      "c",
      "cpp",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "vim",
      "vimdoc",
    }

    treesitter.install(languages)

    local highlight_filetypes = vim.tbl_filter(function(language)
      return language ~= "markdown_inline"
    end, languages)

    local group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = highlight_filetypes,
      callback = function(args)
        vim.treesitter.start(args.buf)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end
}
