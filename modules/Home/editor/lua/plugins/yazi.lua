-- <leader>f は file/find、y は yazi。編集中のファイルの場所から開く。
return {
  "mikavilpas/yazi.nvim",
  lazy = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Yazi",
  keys = {
    { "<leader>fy", "<cmd>Yazi<cr>", desc = "Yazi (Current File)" },
  },
  opts = {
    open_for_directories = false,
    -- <C-t> は既存の右下ターミナルパネル切り替えに使う。
    keymaps = { open_file_in_tab = false },
  },
}
