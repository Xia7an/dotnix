-- snacks explorer のリスト内 <c-t> を、自作の右下ターミナルトグルに差し替える。
-- 既定では snacks 独自の "terminal" アクション(別系統の Snacks.terminal)が
-- 割り当たっており、Explorer にフォーカスがあると global の <c-t> より優先されて
-- しまうため。これで Explorer 上でも同じトグル挙動になる。
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["<c-t>"] = { "toggle_terminal_panel", mode = { "n" } },
              },
            },
          },
          actions = {
            toggle_terminal_panel = function()
              require("config.terminal_tabs").toggle()
            end,
          },
        },
      },
    },
  },
}
