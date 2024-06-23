return {
  {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,

    vim.api.nvim_set_keymap('n', '<leader>u', "<cmd>lua require('undotree').toggle()<cr>", { noremap = true, silent = true, desc = 'Open Undo Tree' }),
  },
}
