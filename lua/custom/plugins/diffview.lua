return {
  {
    'sindrets/diffview.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewRefresh',
      'DiffviewFileHistory',
    },
    keys = {
      {
        '<leader>gd',
        function()
          local lib = require 'diffview.lib'

          lib.dispose_stray_views()

          local current_view = lib.get_current_view()
          if current_view then
            vim.cmd 'DiffviewClose'
            return
          end

          for _, view in ipairs(lib.views or {}) do
            if view.tabpage and vim.api.nvim_tabpage_is_valid(view.tabpage) then
              vim.api.nvim_set_current_tabpage(view.tabpage)
              vim.cmd 'DiffviewClose'
              return
            end
          end

          vim.cmd 'DiffviewOpen'
        end,
        desc = 'Toggle Git [D]iff view',
      },
    },
    opts = {
      keymaps = {
        disable_defaults = false,
      },
      file_panel = {
        listing_style = 'tree',
        tree_options = {
          flatten_dirs = true,
          folder_statuses = 'only_folded',
        },
        win_config = {
          position = 'left',
          width = 35,
        },
      },
    },
  },
}
