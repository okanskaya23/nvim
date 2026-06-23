local function paste_and_format(command)
  return function()
    vim.cmd('normal! ' .. command .. '=`]')
  end
end

vim.keymap.set('n', 'p', paste_and_format 'p', { noremap = true, silent = true, expr = false, replace_keycodes = false })
vim.keymap.set('n', 'P', paste_and_format 'P', { noremap = true, silent = true, expr = false, replace_keycodes = false })
