return {

  -- Old Files
  vim.api.nvim_set_keymap('n', '<leader>fr', ':Telescope oldfiles<CR>', { noremap = true, silent = true, desc = 'Open Recent Files' }),

  --Git
  vim.api.nvim_set_keymap('n', '<leader>g', ':Git<CR>', { noremap = true, silent = true, desc = 'Git' }),

  vim.keymap.set({ 'n', 'x' }, 'd', '"dd', { noremap = true }),
  vim.keymap.set({ 'n', 'x' }, 'D', '"dD', { noremap = true }),
  vim.keymap.set({ 'n', 'x' }, 'x', '"dx', { noremap = true }),
  vim.keymap.set({ 'n', 'x' }, 'X', '"dX', { noremap = true }),
}
