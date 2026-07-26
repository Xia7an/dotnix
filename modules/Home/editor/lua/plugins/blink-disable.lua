return {
  -- blink.cmp を再有効化（前回の無効化を解除）
  { "saghen/blink.cmp", enabled = true },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
          },
        },
      },
      sources = {
        -- .md ファイルでは補完を無効化
        per_filetype = {
          markdown = { inherit_defaults = false },
        },
      },
    },
  },
}
