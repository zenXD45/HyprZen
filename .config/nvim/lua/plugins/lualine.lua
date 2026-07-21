return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons","kdheepak/tabline.nvim" },

    config = function()
        local function current_lualine_theme()
            if vim.g.colors_name == "pywal" then
                return "pywal-nvim"
            end
            return "auto"
        end

        local function setup_lualine()
            require("lualine").setup {
                options = {
                    icons_enabled = true,
                    theme = current_lualine_theme(),
                    component_separators = "",
                    section_separators = { left = "", right = "" },
                    component_separators = { "", "" },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    always_show_tabline = true,
                    globalstatus = false,
                    refresh = {
                        statusline = 100,
                        tabline = 100,
                        winbar = 100,
                    }
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },
                    lualine_c = {},
                    lualine_x = { "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { require("tabline").tabline_buffers },
                    lualine_x = { require("tabline").tabline_tabs },
                    lualine_y = {},
                    lualine_z = {},
                },
                winbar = {},
                inactive_winbar = {},
                extensions = {}
            }
        end

        setup_lualine()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("lualine-theme-sync", { clear = true }),
            callback = function()
                setup_lualine()
                local ok, lualine = pcall(require, "lualine")
                if ok and lualine.refresh then
                    lualine.refresh({ place = { "statusline", "tabline", "winbar" }, trigger = "colorscheme" })
                end
            end,
        })
    end,
}


