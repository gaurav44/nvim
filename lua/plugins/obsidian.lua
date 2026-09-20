return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  cmd = "Obsidian",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New Obsidian note" },
    { "<leader>nf", "<cmd>Obsidian quick_switch<cr>", desc = "Find Obsidian note" },
    { "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search Obsidian vault" },
    { "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "Show Obsidian backlinks" },
    { "<leader>nt", "<cmd>Obsidian tags<cr>", desc = "Search Obsidian tags" },
    { "<leader>no", "<cmd>Obsidian open<cr>", desc = "Open note in Obsidian" },
  },
  ---@module "obsidian"
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "personal",
        path = "/mnt/H/Obsidian Vault",
      },
    },
    picker = {
      name = "telescope.nvim",
    },
  },
}
