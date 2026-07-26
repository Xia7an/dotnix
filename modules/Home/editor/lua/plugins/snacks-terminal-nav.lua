-- Snacks.terminal() 経由で開く端末(LazyVim 標準)でも、右下ドック端末と同様に
-- 隣接ウィンドウが無い方向の Ctrl+hjkl はターミナルへパススルーする
-- (例: 下に窓が無いドック端末で Ctrl+j = Claude Code の改行を奪わないため)
local function smart_nav(dir)
  return function(self)
    if self:is_floating() then
      return "<c-" .. dir .. ">"
    end
    if vim.fn.winnr(dir) == vim.fn.winnr() then
      return "<c-" .. dir .. ">"
    end
    vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      win = {
        keys = {
          nav_h = { "<C-h>", smart_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", smart_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", smart_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", smart_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        },
      },
    },
  },
}
