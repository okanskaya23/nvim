return {
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'gitui',
      },
    },
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('toggleterm').setup {}

      local Terminal = require('toggleterm.terminal').Terminal
      local gitui = nil

      local function create_gitui_terminal()
        return Terminal:new {
          cmd = 'gitui',
          direction = 'float',
          hidden = true,
          on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, 't', 'q', '', {
              noremap = true,
              silent = true,
              callback = function()
                vim.api.nvim_buf_del_keymap(term.bufnr, 't', 'q')
                term:close()
              end,
            })
          end,
        }
      end

      gitui = create_gitui_terminal()

      function _GITUI_TOGGLE()
        gitui:toggle()
      end

      function _GITUI_RESET()
        if gitui then
          gitui:shutdown()
        end
        gitui = create_gitui_terminal()
        vim.notify('GitUI has been reset', vim.log.levels.INFO)
      end

      vim.api.nvim_create_user_command('GitUI', _GITUI_TOGGLE, {})
      vim.api.nvim_create_user_command('GitUIReset', _GITUI_RESET, {})

      vim.keymap.set('n', '<leader>g', _GITUI_TOGGLE, { noremap = true, silent = true, desc = 'Toggle GitUI' })
      vim.keymap.set('n', '<C-g>', _GITUI_RESET, { noremap = true, silent = true, desc = 'Reset GitUI' })
    end,
  },
}
