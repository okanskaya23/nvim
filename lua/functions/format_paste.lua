local function paste_and_format(command)
  return function()
    vim.cmd('normal! ' .. command .. '=`]')
  end
end

vim.keymap.set('n', '<leader>p', paste_and_format 'p', { noremap = true, silent = true, desc = 'Paste and reindent' })
vim.keymap.set('n', '<leader>P', paste_and_format 'P', { noremap = true, silent = true, desc = 'Paste before and reindent' })
