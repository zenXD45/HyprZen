return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = function()
        local state = require("settings_state")
        return {
            preview = {
                enable = state.get("markview_preview", true),
                enable_hybrid_mode = state.get("markview_hybrid", true),
                modes = { "n", "no", "c", "i" },
                hybrid_modes = { "i" },
                linewise_hybrid_mode = true,
                icon_provider = "internal",
                debounce = 80,
                max_buf_lines = 5000,
            },
            experimental = {
                fancy_comments = true,
            },
        }
    end,
};
