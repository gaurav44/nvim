return {
    "stevearc/overseer.nvim",
    config = function()
        require("overseer").setup({
            -- Add your custom configuration here
            strategy = "toggleterm",
            task_list = {
                direction = "bottom",
                min_height = 10,
                max_height = 30,
            },
        })
    end,
}

