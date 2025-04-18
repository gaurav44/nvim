return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { noremap = true, silent = true } },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { noremap = true, silent = true } },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { noremap = true, silent = true } },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { noremap = true, silent = true } },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { noremap = true, silent = true } },
  },
}
