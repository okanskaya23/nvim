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
        auto = true, -- Disable auto plugin detection
      },
      on_highlights = function(hl, c)
        -- Remove background for Normal float (affects Toggleterm)
        hl.NormalFloat = {
          bg = 'NONE',
        }
        -- Remove background for terminal
        hl.Terminal = {
          bg = 'NONE',
        }
        -- Ensure comments are not italic (as per your current config)
        hl.Comment = {
          fg = c.comment,
          italic = false,
        }
      end,
    }

    -- Load the colorscheme
    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
