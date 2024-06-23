return {

  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },

    vim.api.nvim_set_keymap(
      'n',
      '<leader>e',
      "<cmd> lua require('nvim-tree.api').tree.toggle()<cr>",
      { noremap = true, silent = true, desc = 'Open File Tree' }
    ),

    config = function()
      require('nvim-tree').setup {}
    end,
  },
}
