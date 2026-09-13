return {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "zbirenbaum/copilot.lua" },
    },
    opts = {
        window = {
            layout = "vertical",
            width = 0.35,
        },
        auto_insert_mode = true,
    },
}
