return {
  'norcalli/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup({ '*', css = { css = true }, scss = { css = true }, sass = { css = true }, html = { css = true }, javascript = { css = true }, javascriptreact = { css = true }, typescript = { css = true }, typescriptreact = { css = true }, vue = { css = true } }, {
      RGB = true,
      RRGGBB = true,
      RRGGBBAA = true,
      names = true,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      mode = 'background',
    })
  end
}
