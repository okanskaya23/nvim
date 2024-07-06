return {
  vim.keymap.set({ 'n', 'x' }, 'd', '"dd', { noremap = true }),
  vim.keymap.set({ 'n', 'x' }, 'D', '"dD', { noremap = true }),
  vim.keymap.set({ 'n', 'x' }, 'x', '"dx', { noremap = true }),
  vim.keymap.set({ 'n', 'x' }, 'X', '"dX', { noremap = true }),
}
