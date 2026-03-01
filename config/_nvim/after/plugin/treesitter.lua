-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  ensure_installed = {}, -- Nixで管理するため空にする
  auto_install = false,
}

-- Context commentstring
require('ts_context_commentstring').setup({
  enable_autocmd = false,
})


