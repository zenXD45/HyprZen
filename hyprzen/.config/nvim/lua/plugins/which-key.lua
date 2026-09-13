local function set_theme_icon_highlights()
    local theme_icon_colors = {
        ThemeIconPywal = vim.g.color5 or "#c792ea",
        ThemeIconTokyoNight = "#7aa2f7",
        ThemeIconGruvbox = "#fabd2f",
        ThemeIconKanagawa = "#7e9cd8",
        ThemeIconCatppuccin = "#c6a0f6",
        ThemeIconRosePine = "#eb6f92",
        ThemeIconNord = "#88c0d0",
        ThemeIconEverforest = "#a7c080",
        ThemeIconOneDark = "#98c379",
        ThemeIconCarbonfox = "#82aaff",
        ThemeIconGithub = "#539bf5",
        ThemeIconVSCode = "#569cd6",
        ThemeIconGruvboxMaterial = "#d8a657",
    }

    for group, fg in pairs(theme_icon_colors) do
        vim.api.nvim_set_hl(0, group, { fg = fg, bold = true })
    end
end

return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 150,
        spec = {
            { "<leader>a", group = "AI (Copilot)" },
            { "<leader>f", group = "Find (Telescope)" },
            { "<leader>l", group = "LSP" },
            { "<leader>g", group = "Git" },
            { "<leader>u", group = "UI" },
            { "<leader>uc", group = "Completion" },
            { "<leader>um", group = "Markdown" },
            { "<leader>ut", group = "Theme" },
            { "<leader>utp", icon = { icon = "󰸉", hl = "ThemeIconPywal" } },
            { "<leader>utt", icon = { icon = "", hl = "ThemeIconTokyoNight" } },
            { "<leader>utg", icon = { icon = "󰔉", hl = "ThemeIconGruvbox" } },
            { "<leader>utk", icon = { icon = "󱨛", hl = "ThemeIconKanagawa" } },
            { "<leader>utc", icon = { icon = "󰄛", hl = "ThemeIconCatppuccin" } },
            { "<leader>utr", icon = { icon = "󰴐", hl = "ThemeIconRosePine" } },
            { "<leader>utn", icon = { icon = "󰼔", hl = "ThemeIconNord" } },
            { "<leader>ute", icon = { icon = "󰔄", hl = "ThemeIconEverforest" } },
            { "<leader>uto", icon = { icon = "󰽥", hl = "ThemeIconOneDark" } },
            { "<leader>utf", icon = { icon = "󰆌", hl = "ThemeIconCarbonfox" } },
            { "<leader>uth", icon = { icon = "", hl = "ThemeIconGithub" } },
            { "<leader>utv", icon = { icon = "", hl = "ThemeIconVSCode" } },
            { "<leader>utm", icon = { icon = "󰔉", hl = "ThemeIconGruvboxMaterial" } },
            { "<leader>x", group = "Tools" },
            { "<leader>q", group = "Quit" },
            { "<leader>w", group = "Write" },
        },
    },
    config = function(_, opts)
        require("which-key").setup(opts)

        set_theme_icon_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("which-key-theme-icon-colors", { clear = true }),
            callback = function()
                set_theme_icon_highlights()
            end,
        })
    end,
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
        {
            "<leader>ap",
            function()
                local ok, chat = pcall(require, "CopilotChat")
                if not ok then
                    return
                end
                local previous = vim.opt.splitright:get()
                vim.opt.splitright = true
                chat.toggle()
                vim.opt.splitright = previous
            end,
            desc = "CopilotChat: Toggle Right Panel",
        },
        {
            "<leader>ao",
            function()
                local ok, chat = pcall(require, "CopilotChat")
                if not ok then
                    return
                end
                local previous = vim.opt.splitright:get()
                vim.opt.splitright = true
                chat.open()
                vim.opt.splitright = previous
            end,
            desc = "CopilotChat: Open Right Panel",
        },
        {
            "<leader>ac",
            "<cmd>CopilotChatClose<CR>",
            desc = "CopilotChat: Close Panel",
        },
        {
            "<leader>ar",
            "<cmd>CopilotChatReset<CR>",
            desc = "CopilotChat: Reset Chat",
        },
        {
            "<leader>as",
            "<cmd>CopilotChatStop<CR>",
            desc = "CopilotChat: Stop Response",
        },
        {
            "<leader>aa",
            "<cmd>Copilot auth<CR>",
            desc = "Copilot: Authenticate",
        },
        {
            "<leader>utp",
            function()
                require("ui_theme").use_pywal()
            end,
            desc = "Theme: Full Pywal",
        },
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Find Files",
        },
        {
            "<leader>fg",
            function()
                require("telescope.builtin").live_grep()
            end,
            desc = "Live Grep",
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Find Buffers",
        },
        {
            "<leader>fh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "Help Tags",
        },
        {
            "<leader>fo",
            function()
                require("telescope.builtin").oldfiles()
            end,
            desc = "Recent Files",
        },
        {
            "<leader>fr",
            function()
                require("telescope.builtin").resume()
            end,
            desc = "Resume Last Picker",
        },
        {
            "<leader>fk",
            function()
                require("telescope.builtin").keymaps()
            end,
            desc = "Find Keymaps",
        },
        {
            "<leader>fc",
            function()
                require("telescope.builtin").commands()
            end,
            desc = "Find Commands",
        },
        {
            "<leader>fd",
            function()
                require("telescope.builtin").diagnostics()
            end,
            desc = "Find Diagnostics",
        },
        {
            "<leader>fD",
            function()
                _G.search_and_scope_into_directory()
            end,
            desc = "Find Directory and cd",
        },
        {
            "<leader>umt",
            function()
                require("ui_settings").toggle_markview_preview()
            end,
            desc = "Markdown Preview Toggle",
        },
        {
            "<leader>umh",
            function()
                require("ui_settings").toggle_markview_hybrid()
            end,
            desc = "Markdown Hybrid Toggle",
        },
        {
            "<leader>umr",
            "<cmd>Markview Render<CR>",
            desc = "Markdown Render All",
        },
        {
            "<leader>xl",
            "<cmd>Lazy<CR>",
            desc = "Open Lazy",
        },
        {
            "<leader>xm",
            "<cmd>Mason<CR>",
            desc = "Open Mason",
        },
        {
            "<leader>ws",
            "<cmd>w<CR>",
            desc = "Write Buffer",
        },
        {
            "<leader>qq",
            "<cmd>qa<CR>",
            desc = "Quit All",
        },
        {
            "<leader>qQ",
            "<cmd>qa!<CR>",
            desc = "Force Quit All",
        },
        {
            "<leader>ucc",
            function()
                _G.toggle_cmp_mode()
            end,
            desc = "Completion: Cycle Mode",
        },
        {
            "<leader>uci",
            function()
                _G.set_cmp_mode("inline")
            end,
            desc = "Completion: Inline-Only",
        },
        {
            "<leader>ucm",
            function()
                _G.set_cmp_mode("menu")
            end,
            desc = "Completion: Menu + Inline",
        },
        {
            "<leader>uco",
            function()
                _G.set_cmp_mode("off")
            end,
            desc = "Completion: Off",
        },
        {
            "<leader>utt",
            function()
                require("ui_theme").apply_theme("tokyonight")
            end,
            desc = "Theme: TokyoNight",
        },
        {
            "<leader>utg",
            function()
                require("ui_theme").apply_theme("gruvbox")
            end,
            desc = "Theme: Gruvbox",
        },
        {
            "<leader>utk",
            function()
                require("ui_theme").apply_theme("kanagawa")
            end,
            desc = "Theme: Kanagawa",
        },
        {
            "<leader>utc",
            function()
                require("ui_theme").apply_theme("catppuccin-macchiato")
            end,
            desc = "Theme: Catppuccin Macchiato",
        },
        {
            "<leader>utr",
            function()
                require("ui_theme").apply_theme("rose-pine")
            end,
            desc = "Theme: Rose Pine",
        },
        {
            "<leader>utn",
            function()
                require("ui_theme").apply_theme("nord")
            end,
            desc = "Theme: Nord",
        },
        {
            "<leader>ute",
            function()
                require("ui_theme").apply_theme("everforest")
            end,
            desc = "Theme: Everforest",
        },
        {
            "<leader>uto",
            function()
                require("ui_theme").apply_theme("onedark")
            end,
            desc = "Theme: OneDark",
        },
        {
            "<leader>utf",
            function()
                require("ui_theme").apply_theme("carbonfox")
            end,
            desc = "Theme: Carbonfox",
        },
        {
            "<leader>uth",
            function()
                require("ui_theme").apply_theme("github_dark_dimmed")
            end,
            desc = "Theme: GitHub Dark Dimmed",
        },
        {
            "<leader>utv",
            function()
                require("ui_theme").apply_theme("vscode")
            end,
            desc = "Theme: VSCode",
        },
        {
            "<leader>utm",
            function()
                require("ui_theme").apply_theme("gruvbox-material")
            end,
            desc = "Theme: Gruvbox Material",
        },
    },
}
