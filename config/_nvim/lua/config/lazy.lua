-- Nixでプラグイン管理を行うための設定
-- 基本設定
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 基本オプション
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- カラースキームを設定
-- tokyonightなどのcolorscheme設定は、after/plugin/で実行されると遅すぎる可能性がある（ちらつきなど）。
-- しかし、init.luaの時点でロードされていないなら、vim.cmd colorschemeも失敗する可能性がある。
-- もし失敗していたなら、ここでpcallすべきか、あるいはcolorscheme設定だけはafterに残すべきか。
-- いったんそのままにする。
vim.cmd([[colorscheme tokyonight]])
