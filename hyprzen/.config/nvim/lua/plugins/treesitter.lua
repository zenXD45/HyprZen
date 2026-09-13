-- treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
      auto_install = true,  -- installs missing parsers automatically
      highlight = { enable = true },
      indent = { enable = true },
  },
}
