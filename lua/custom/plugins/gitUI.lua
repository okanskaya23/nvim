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

      local function open_gitui()
        local git_dir = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
        local dir = git_dir or vim.fn.getcwd()
        local term = require('toggleterm').exec('gitui', 1, 12, dir, 'float')
        return term.id
      end

      local function close_gitui(term_id)
        local term = require('toggleterm').get_or_create_term(term_id)
        if term then
          term:close()
        end
      end

      -- Create a custom command
      vim.api.nvim_create_user_command('GitUI', function()
        local term_id = open_gitui()
        -- Set up an autocommand to map 'q' to close GitUI in this specific terminal buffer
        vim.api.nvim_create_autocmd('TermEnter', {
          pattern = '*',
          callback = function()
            vim.api.nvim_buf_set_keymap(0, 't', 'q', '', {
              noremap = true,
              silent = true,
              callback = function()
                close_gitui(term_id)
              end,
            })
          end,
          once = true,
        })
      end, {})

      vim.keymap.set('n', '<leader>g', open_gitui, { noremap = true, silent = true, desc = 'Open GitUI' })
    end,
  },
}
