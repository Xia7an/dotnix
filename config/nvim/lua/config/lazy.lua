-- Nixでプラグイン管理を行うための設定
-- 基本設定
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 基本オプション
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- カラースキームを設定
vim.cmd([[colorscheme tokyonight]])

-- プラグイン設定の読み込み
local function load_plugin_config(module_name)
  local ok, err = pcall(require, module_name)
  if not ok then
    vim.notify("Failed to load " .. module_name .. ": " .. tostring(err), vim.log.levels.WARN)
  end
end

-- プラグイン設定
local plugin_configs = {
  -- UI
  "plugins.bufferline",
  "plugins.lualine",
  "plugins.indent-blankline",
  "plugins.noice",
  "plugins.dressing",
  
  -- Editor
  "plugins.neo-tree",
  "plugins.which-key",
  "plugins.telescope",
  "plugins.flash",
  "plugins.gitsigns",
  "plugins.trouble",
  "plugins.todo-comments",
  "plugins.illuminate",
  
  -- LSP & Completion
  "plugins.neodev",
  "plugins.lsp",
  "plugins.cmp",
  
  -- Treesitter
  "plugins.treesitter",
  
  -- Coding
  "plugins.autopairs",
  "plugins.comment",
  "plugins.mini",
  
  -- Terminal
  "plugins.toggleterm",
}

for _, module in ipairs(plugin_configs) do
  load_plugin_config(module)
end


