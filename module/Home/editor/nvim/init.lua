-- lazy.nvim を runtimepath に追加
vim.opt.rtp:prepend(
  vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
)

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight", "catppuccin" } },
  checker = { enabled = false },
})
