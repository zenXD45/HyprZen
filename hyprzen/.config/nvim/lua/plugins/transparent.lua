return {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
        require("transparent").setup({
            groups = {
                'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
                'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
                'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
                'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
                'EndOfBuffer',
            },
            extra_groups = {
                "NormalFloat", "FloatBorder", "TelescopeNormal", "TelescopeBorder",
                "TelescopePromptBorder", "SagaBorder", "SagaNormal", "NeoTreeNormal",
                "NeoTreeNormalNC", "NeoTreeFloatNormal", "NeoTreeFloatBorder",
                "WhichKeyFloat", "NotifyBackground"
            },
            exclude_groups = {},
        })
        -- Optional: clear prefix groups
        require('transparent').clear_prefix('BufferLine')
        require('transparent').clear_prefix('NeoTree')
        require('transparent').clear_prefix('lualine')
    end
}
