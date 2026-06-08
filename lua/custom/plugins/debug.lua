return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    local function executable(name)
      local mason_path = vim.fn.stdpath 'data' .. '/mason/bin/' .. name
      if vim.fn.executable(mason_path) == 1 then
        return mason_path
      end

      local path = vim.fn.exepath(name)
      return path ~= '' and path or name
    end

    dap.adapters.coreclr = {
      type = 'executable',
      command = executable 'netcoredbg',
      args = { '--interpreter=vscode' },
    }

    if vim.fn.has 'win32' == 1 then
      dap.adapters.coreclr.options = {
        detached = false,
      }
    end

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Launch .NET assembly',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
      },
      {
        type = 'coreclr',
        name = 'Attach to .NET process',
        request = 'attach',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
      },
    }

    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
