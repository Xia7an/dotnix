-- Which-key configuration
local wk = require("which-key")

wk.setup({
  preset = "modern",
  delay = 200,
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = false,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  win = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
  layout = {
    spacing = 3,
    align = "left",
  },
  show_help = true,
  show_keys = true,
})

-- Leader key group names
wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>f", group = "file/find" },
  { "<leader>g", group = "git" },
  { "<leader>gh", group = "hunks" },
  { "<leader>q", group = "quit/session" },
  { "<leader>s", group = "search" },
  { "<leader>u", group = "ui" },
  { "<leader>w", group = "windows" },
  { "<leader>x", group = "diagnostics/quickfix" },
  { "<leader><tab>", group = "tabs" },
  { "g", group = "goto" },
  { "gs", group = "surround" },
  { "]", group = "next" },
  { "[", group = "prev" },
})


