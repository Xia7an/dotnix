-- Mini.nvim configurations
-- Mini.ai - better text objects
require('mini.ai').setup({
  n_lines = 500,
  custom_textobjects = {
    o = require('mini.ai').gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }, {}),
    f = require('mini.ai').gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
    c = require('mini.ai').gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
  },
})

-- Mini.surround - surround text objects
require('mini.surround').setup({
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
  },
})

-- Mini.bufremove - better buffer deletion
require('mini.bufremove').setup()

vim.keymap.set('n', '<leader>bd', function()
  require('mini.bufremove').delete(0, false)
end, { desc = 'Delete Buffer' })

vim.keymap.set('n', '<leader>bD', function()
  require('mini.bufremove').delete(0, true)
end, { desc = 'Delete Buffer (Force)' })
