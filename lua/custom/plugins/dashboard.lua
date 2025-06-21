return {
  'nvimdev/dashboard-nvim',
  lazy = false,
  opts = function()
    local logo = [[

██╗   ██╗██╗███╗   ███╗
██║   ██║██║████╗ ████║
██║   ██║██║██╔████╔██║
╚██╗ ██╔╝██║██║╚██╔╝██║
 ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                       

    ]]

    logo = string.rep('\n', 8) .. logo .. '\n\n'

    local opts = {
      theme = 'doom',
      hide = {
        statusline = false,
      },
      config = {
        header = vim.split(logo, '\n'),
        center = {
          {
            action = 'Telescope find_files',
            desc = ' Find File',
            icon = '󰍉',
            key = 'f',
          },
          {
            action = 'Telescope oldfiles',
            desc = ' Old Files',
            icon = '󰪶',
            key = 'o',
          },
          {
            action = 'NvimTreeToggle',
            desc = ' File Tree',
            icon = '',
            key = 'e',
          },
          {
            action = function()
              _LAZYGIT_TOGGLE()
            end,
            desc = ' LazyGit',
            icon = '󰊢',
            key = 'g',
          },
          {
            action = 'VimBeGood',
            desc = ' Vim Be Good',
            icon = '󱩁',
            key = 't',
          },
          {
            action = 'checkhealth',
            desc = ' Check Health',
            icon = '',
            key = 'h',
          },
          {
            action = function()
              vim.api.nvim_input '<cmd>qa<cr>'
            end,
            desc = ' Quit',
            icon = '󰒲',
            key = 'q',
          },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
      button.key_format = '  %s'
    end

    -- open dashboard after closing lazy
    if vim.o.filetype == 'lazy' then
      vim.api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(vim.api.nvim_get_current_win()),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.api.nvim_exec_autocmds('UIEnter', { group = 'dashboard' })
          end)
        end,
      })
    end

    return opts
  end,
}
