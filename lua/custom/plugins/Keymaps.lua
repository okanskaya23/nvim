return {

  -- Old Files
  vim.api.nvim_set_keymap('n', '<leader>fr', ':Telescope oldfiles<CR>', { noremap = true, silent = true, desc = 'Open Recent Files' }),

  --Git
  vim.api.nvim_set_keymap('n', '<leader>g', ':Git<CR>', { noremap = true, silent = true, desc = 'Git' }),

  -- restore the session for the current directory
  vim.api.nvim_set_keymap('n', '<leader>qs', [[<cmd>lua require("persistence").load()<cr>]], {}),

  -- restore the last session
  vim.api.nvim_set_keymap('n', '<leader>ql', [[<cmd>lua require("persistence").load({ last = true })<cr>]], {}),

  -- stop Persistence => session won't be saved on exit
  vim.api.nvim_set_keymap('n', '<leader>qd', [[<cmd>lua require("persistence").stop()<cr>]], {}),
}
