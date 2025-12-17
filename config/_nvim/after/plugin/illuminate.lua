-- Vim-illuminate configuration
require('illuminate').configure({
  providers = {
    'lsp',
    'treesitter',
    'regex',
  },
  delay = 100,
  filetype_overrides = {},
  filetypes_denylist = {
    'dirvish',
    'fugitive',
    'neo-tree',
  },
  under_cursor = true,
  large_file_cutoff = 2000,
  large_file_overrides = nil,
  min_count_to_highlight = 1,
})

-- Keymaps
vim.keymap.set('n', ']]', function() require('illuminate').goto_next_reference(false) end, { desc = 'Next Reference' })
vim.keymap.set('n', '[[', function() require('illuminate').goto_prev_reference(false) end, { desc = 'Prev Reference' })
