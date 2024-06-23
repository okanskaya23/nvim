return {
  vim.api.nvim_set_keymap('n', '<leader>fr', ':Telescope oldfiles<CR>', { noremap = true, silent = true, desc = 'Open Recent Files' }),
}
