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
      require('toggleterm').setup {
        -- your toggleterm configuration here
        -- or leave it empty to use the default settings
      }

      local function open_gitui()
        local git_dir = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
        local dir = git_dir or vim.fn.getcwd()
        require('toggleterm').exec('gitui', 1, 12, dir, 'float')
      end

      -- Create a custom command
      vim.api.nvim_create_user_command('GitUI', open_gitui, {})

      -- Set the keymapping
      vim.keymap.set('n', '<leader>gu', open_gitui, { noremap = true, silent = true, desc = 'Open GitUI' })
    end,
  },
}
