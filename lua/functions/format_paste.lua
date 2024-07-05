vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('FormatPaste', { clear = true }),
  callback = function()
    vim.keymap.set('n', 'p', function()
      vim.cmd 'normal! p=`]'
    end, { noremap = true, silent = true, expr = false, replace_keycodes = false })

    vim.keymap.set('n', 'P', function()
      vim.cmd 'normal! P=`]'
    end, { noremap = true, silent = true, expr = false, replace_keycodes = false })
  end,
})
