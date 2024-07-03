return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {}
      local map = vim.api.nvim_set_keymap

      options = { noremap = true, silent = true }

      map('n', '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', options)
      map('n', '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', options)
      map('n', '<leader>br', '<Cmd>BufferLineCloseRight<CR>', options)
      map('n', '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', options)
      map('n', '<leader>bb', '<Cmd>BufferLinePick<CR>', options)
      map('n', '<leader>bc', '<Cmd>BufferLinePickClose<CR>', options)
    end,
  },
}
