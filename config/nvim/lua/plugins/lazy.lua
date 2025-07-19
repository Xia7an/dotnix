-- lua/plugins/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  -- cloneしないよ！Nixでインストールされてるから！
  print("Lazy.nvim is not installed at: " .. lazypath)
  return
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- プラグインリスト（Nixで管理しない場合）
})

