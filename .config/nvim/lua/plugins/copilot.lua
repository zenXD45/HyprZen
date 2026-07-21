return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
        suggestion = {
            enabled = false,
        },
        panel = {
            enabled = false,
            auto_refresh = true,
            layout = {
                position = "right",
                ratio = 0.35,
            },
        },
        filetypes = {
            markdown = true,
            help = false,
            gitcommit = true,
            gitrebase = false,
            ["."] = true,
        },
    },
}
