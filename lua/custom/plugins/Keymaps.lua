return {

  -- Old Files
  vim.api.nvim_set_keymap('n', '<leader>fr', ':Telescope oldfiles<CR>', { noremap = true, silent = true, desc = 'Open Recent Files' }),

  --Git
  vim.api.nvim_set_keymap('n', '<leader>G', ':Git<CR>', { noremap = true, silent = true, desc = 'Git' }),
}
