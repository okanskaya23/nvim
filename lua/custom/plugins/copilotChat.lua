return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- Map <leader>ac to :CopilotChatOpen with description
  vim.api.nvim_set_keymap('n', '<leader>ac', ':CopilotChatToggle<CR>', { noremap = true, silent = true, desc = 'Open Copilot Chat' }),
  vim.api.nvim_set_keymap('v', '<leader>ao', ':CopilotChatOptimize<CR>', { noremap = true, silent = true, desc = 'Open Copilot Chat' }),
}
