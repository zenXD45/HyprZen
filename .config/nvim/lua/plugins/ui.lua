return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 100000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}

