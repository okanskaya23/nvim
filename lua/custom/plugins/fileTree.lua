return {

  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },

    keys = { -- load the plugin only when using it's keybinding:
        { '<leader>e', "<cmd> lua require('nvim-tree.api').tree.toggle()<cr>", { desc = 'Toggle Nvim Tree' } }
    },

    config = function()
      require('nvim-tree').setup {}
    end,
  },
}
