return {
  'folke/tokyonight.nvim',
  priority = 1000,
  config = function()
    require('tokyonight').setup {
      style = 'night',
      light_style = 'day',
      transparent = false,
      terminal_colors = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = 'dark',
        floats = 'dark',
      },
      day_brightness = 0.3,
      dim_inactive = false,
      lualine_bold = false,
      plugins = {
        auto = true,
      },
      on_highlights = function(hl, c)
        hl.NormalFloat = {
          bg = 'NONE',
        }
        hl.Terminal = {
          bg = 'NONE',
        }
        hl.Comment = {
          fg = c.comment,
          italic = false,
        }
      end,
    }
    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
