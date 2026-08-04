---@module 'lazy'
---@type LazySpec

return {
  {
    'HiPhish/rainbow-delimiters.nvim',
    submodules = false,
    config = function()
      local apply_oasis_rainbow = function()
        local palette = require('oasis.palette').terminal
        local groups = {
          RainbowDelimiterRed = palette.red,
          RainbowDelimiterOrange = palette.bright_yellow,
          RainbowDelimiterYellow = palette.yellow,
          RainbowDelimiterGreen = palette.green,
          RainbowDelimiterCyan = palette.cyan,
          RainbowDelimiterBlue = palette.blue,
          RainbowDelimiterViolet = palette.magenta,
        }

        for group, color in pairs(groups) do
          vim.api.nvim_set_hl(0, group, { fg = color })
        end
      end

      apply_oasis_rainbow()
      vim.api.nvim_create_autocmd('ColorScheme', {
        desc = 'Re-apply oasis colors to rainbow-delimiters',
        callback = apply_oasis_rainbow,
      })
    end,
  },
}
