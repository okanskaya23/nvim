return {
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local function nvim_tree_toggle_and_find()
        local nvim_tree = require 'nvim-tree.api'
        local current_buf = vim.api.nvim_get_current_buf()
        if vim.bo[current_buf].filetype == 'NvimTree' then
          nvim_tree.tree.toggle()
        else
          if not nvim_tree.tree.is_visible() then
            nvim_tree.tree.open()
          end
          nvim_tree.tree.find_file { open = true, focus = true }
        end
      end

      vim.keymap.set('n', '<leader>e', nvim_tree_toggle_and_find, { noremap = true, silent = true, desc = 'Toggle NvimTree' })

      require('nvim-tree').setup {
        filters = {
          dotfiles = false, -- Show dotfiles
          custom = { '^.git$', '^node_modules$', '.meta', '^LICENSE$' }, -- Ignore files/dirs
          --exclude = { '.gitignore' }, -- Don't ignore .gitignore
        },
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 30,
        },
        renderer = {
          highlight_git = true,
          highlight_opened_files = 'all',
        },
      }
    end,
  },
}
