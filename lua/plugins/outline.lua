return {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup({
        -- Default options
        symbols = {
          -- Icons for different types of symbols
          icons = {
            File = { icon = "📄", hl = "Identifier" },
            Module = { icon = "📦", hl = "Include" },
            Namespace = { icon = "🔰", hl = "Include" },
            Package = { icon = "📦", hl = "Include" },
            Class = { icon = "🔶", hl = "Type" },
            Method = { icon = "ƒ", hl = "Function" },
            Property = { icon = "🔧", hl = "Identifier" },
            Field = { icon = "🔧", hl = "Identifier" },
            Constructor = { icon = "⚙️", hl = "Special" },
            Enum = { icon = "🔢", hl = "Type" },
            Interface = { icon = "🔗", hl = "Type" },
            Function = { icon = "λ", hl = "Function" },
            Variable = { icon = "𝑥", hl = "Constant" },
            Constant = { icon = "𝐾", hl = "Constant" },
            String = { icon = "🔤", hl = "String" },
            Number = { icon = "#", hl = "Number" },
            Boolean = { icon = "⊨", hl = "Boolean" },
            Array = { icon = "[]", hl = "Constant" },
            Object = { icon = "⦿", hl = "Type" },
            Key = { icon = "🔑", hl = "Type" },
            Null = { icon = "ø", hl = "Type" },
            EnumMember = { icon = "🔢", hl = "Identifier" },
            Struct = { icon = "𝓢", hl = "Type" },
            Event = { icon = "🔅", hl = "Type" },
            Operator = { icon = "=", hl = "Operator" },
            TypeParameter = { icon = "𝙏", hl = "Type" },
          },
        },
        outline_window = {
          -- Width of the outline window
          width = 45,
          -- Auto-focus outline window when opened
          auto_focus = true,
          -- Show help hint at the top of the outline window
          show_help = true,
          -- Show code details (e.g. signature) for symbols
          show_symbol_details = true,
          -- Highlight current symbol
          highlight_current_item = true,
        },
        -- Set to true to update the outline automatically
        outline_items = {
          -- Follow cursor and auto-focus on the symbol at cursor
          follow_cursor = true,
          -- Auto-expand items under cursor
          auto_expand = true,
        },
        -- Include these kinds of symbols in the outline
        symbol_folding = {
          -- Fold all by default
          autofold_depth = 1,
        },
        -- Language specific settings
        guides = {
          -- Lines connecting symbols
          enabled = true,
          markers = {
            bottom = "└",
            middle = "├",
            vertical = "│",
          },
        },
        -- Preview window for symbol under cursor
        preview_window = {
          -- Auto open preview of symbol under cursor
          auto_preview = true,
          -- Border style
          border = "single",
        },
        -- Keymaps in the outline window
        keymaps = {
          -- Toggle the outline window
          close = "q",
          -- Go to the symbol under cursor
          goto_location = "<CR>",
          -- Expand or collapse symbol under cursor
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
        -- Show diagnostics alongside symbols
        providers = {
          -- Include LSP symbols
          lsp = {
            enabled = true,
          },
          -- Include treesitter symbols (can be more accurate)
          treesitter = {
            enabled = true,
          },
          -- Include diagnostics (errors, warnings, etc)
          diagnostics = {
            enabled = true,
            include_severity_levels = { "error", "warning", "info", "hint" },
          },
        }
      })
      
      -- Add keymaps for outline.nvim (commented out as it's now in which-key.nvim)
      -- vim.keymap.set("n", "<leader>o", "<cmd>Outline<cr>", { desc = "Toggle Outline" })
    end,
  }
