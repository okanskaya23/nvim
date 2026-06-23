return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    cmd = {
      'CopilotChat',
      'CopilotChatOpen',
      'CopilotChatToggle',
      'CopilotChatOptimize',
    },
    keys = {
      { '<leader>ac', '<cmd>CopilotChatToggle<cr>', mode = 'n', desc = 'Open Copilot Chat' },
      { '<leader>ao', '<cmd>CopilotChatOptimize<cr>', mode = 'v', desc = 'Optimize with Copilot Chat' },
    },
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = false,
      -- See Configuration section for rest
    },
  },
}
