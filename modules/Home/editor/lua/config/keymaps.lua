-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 右下のターミナルパネルに新しいタブを開く。
-- タブ間の切り替えは各ターミナルバッファに割り当てられる H / L で行う
-- (config/terminal_tabs.lua)。編集ファイルの bufferline とは独立。
vim.keymap.set("n", "<leader>tn", function()
  require("config.terminal_tabs").new()
end, { desc = "New Terminal Tab" })

-- Ctrl+t で右下ターミナルの表示/非表示をトグル。
-- 消えた(隠した)ターミナルもこれで右下に復帰できる。
-- ターミナル内(Terminal-mode)からも効くよう t モードにも割り当てる。
vim.keymap.set({ "n", "t" }, "<c-t>", function()
  require("config.terminal_tabs").toggle()
end, { desc = "Toggle Terminal Panel" })
