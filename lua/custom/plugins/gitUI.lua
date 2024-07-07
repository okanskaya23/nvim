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
      local gitui = Terminal:new {
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

      function _GITUI_TOGGLE()
        gitui:toggle()
      end

      vim.api.nvim_create_user_command('GitUI', _GITUI_TOGGLE, {})

      vim.keymap.set('n', '<leader>g', _GITUI_TOGGLE, { noremap = true, silent = true, desc = 'Toggle GitUI' })
    end,
  },
}
