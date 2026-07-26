-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- `nvim` を引数なし、または単一のディレクトリ引数で起動したときに
-- 左側に Explorer、右下にターミナルを表示するレイアウトを組む
--
-- このファイル自体が `VeryLazy`(= VimEnter より後)で読み込まれるため、
-- ここで `VimEnter` オートコマンドを登録してもイベントは発火済みで二度と
-- 呼ばれない。読み込み時点で直接判定・実行する。
do
  local argc = vim.fn.argc(-1)
  local is_dir = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
  local no_args = argc == 0

  if no_args or is_dir then
    vim.schedule(function()
      -- ディレクトリ起動時は replace_netrw により Explorer が既に開いているので
      -- 引数なし起動のときだけ明示的に開く
      if no_args then
        Snacks.explorer()
      end

      -- 右下にターミナルタブ(1つ目)を開く。ウィンドウの確保・split・
      -- unlisted 化・タブ切り替え(H/L)はすべて config.terminal_tabs 側で行う
      require("config.terminal_tabs").new()
      vim.cmd("wincmd k")
      vim.cmd("stopinsert")
    end)
  end
end
