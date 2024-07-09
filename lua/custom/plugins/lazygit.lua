return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('toggleterm').setup {}

      local Terminal = require('toggleterm.terminal').Terminal

      -- LazyGit Configuration
      local lazygit = nil

      local function create_lazygit_terminal()
        return Terminal:new {
          cmd = 'lazygit',
          dir = 'git_dir',
          direction = 'float',
          float_opts = {
            border = 'double',
          },
          on_open = function(term)
            vim.cmd 'startinsert!'
            vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
          end,
          on_close = function()
            vim.cmd 'startinsert!'
          end,
        }
      end

      lazygit = create_lazygit_terminal()

      function _LAZYGIT_TOGGLE()
        lazygit:toggle()
      end

      function _LAZYGIT_RESET()
        if lazygit then
          lazygit:shutdown()
        end
        lazygit = create_lazygit_terminal()
        vim.notify('LazyGit has been reset', vim.log.levels.INFO)
      end

      -- User Commands
      vim.api.nvim_create_user_command('LazyGit', _LAZYGIT_TOGGLE, {})
      vim.api.nvim_create_user_command('LazyGitReset', _LAZYGIT_RESET, {})

      -- Keymaps
      vim.keymap.set('n', '<leader>g', _LAZYGIT_TOGGLE, { noremap = true, silent = true, desc = 'Toggle LazyGit' })
      vim.keymap.set('n', '<C-g>', _LAZYGIT_RESET, { noremap = true, silent = true, desc = 'Reset LazyGit' })
    end,
  },
}
