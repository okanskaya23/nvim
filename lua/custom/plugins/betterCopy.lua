return {
  -- Existing keymaps...

  function()
    -- Set clipboard to empty by default
    vim.opt.clipboard = ''

    -- Create a user command to copy selected text to system clipboard
    vim.api.nvim_create_user_command('CopyTextCommand', function(opts)
      -- Store the original clipboard setting
      local original_clipboard = vim.opt.clipboard:get()

      -- Temporarily set clipboard to unnamedplus
      vim.opt.clipboard = 'unnamedplus'

      -- Yank the selected text
      if opts.range == 0 then
        -- If no range is specified, use the current line
        vim.cmd 'normal! yy'
      else
        -- If a range is specified, yank that range
        vim.cmd(opts.line1 .. ',' .. opts.line2 .. 'y')
      end

      -- Restore the original clipboard setting
      vim.opt.clipboard = original_clipboard

      print 'Text copied to system clipboard'
    end, { range = true })

    -- Map <leader>y to the CopyTextCommand in visual mode
    vim.api.nvim_set_keymap('v', '<leader>y', ':CopyTextCommand<CR>', { noremap = true, silent = true, desc = 'Copy to system clipboard' })

    -- Map <leader>p to paste from system clipboard in normal mode
    vim.api.nvim_set_keymap('n', '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })

    -- Map <leader>P to paste from system clipboard in insert mode
    vim.api.nvim_set_keymap('i', '<leader>P', '<C-r>+', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
  end,
}
