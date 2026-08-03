-- 右サイドの AI エージェントパネル (folke/sidekick.nvim)。
-- Claude Code と Codex を同じ右分割ウィンドウで切り替えて使う。
-- 各ツールはただの CLI をターミナルで起動するだけなので、認証や設定は
-- それぞれの CLI (~/.claude, ~/.codex) 側の設定に従う。
--
-- ベースの spec と <leader>a* のキーマップは
-- lazyvim.plugins.extras.ai.sidekick (neovim.nix で import) が持っている。
-- ここではそこに載らない部分だけを上書きする。

--- 指定したエージェントの右パネルをトグルする。
--- sidekick は素直に show すると開いている数だけ右に縦分割を積んでしまい、
--- 2つ開くと編集領域が潰れる。ここでは他のエージェントを畳んでから出すことで
--- 「右パネルは常に1枚」を保つ (畳むだけなのでセッションと会話は残る)。
---@param name string
local function toggle(name)
  return function()
    local Cli = require("sidekick.cli")
    local visible = false

    for _, w in ipairs(vim.api.nvim_list_wins()) do
      local tool = vim.b[vim.api.nvim_win_get_buf(w)].sidekick_cli
      if tool then
        if tool.name == name then
          visible = true
        else
          Cli.hide({ name = tool.name })
        end
      end
    end

    if visible then
      Cli.hide({ name = name })
    else
      Cli.show({ name = name, focus = true })
    end
  end
end

return {
  "folke/sidekick.nvim",
  opts = {
    -- NES (Copilot の next edit suggestion) は copilot-language-server と
    -- Copilot のサブスクリプションが要るので使わない。
    -- extras/ai/sidekick.lua はこの値を見て lspconfig への copilot サーバ登録を
    -- 止めるので、false にしておけば LSP 側も起動しない。
    nes = { enabled = false },
    cli = {
      -- CLI がファイルを書き換えたら Neovim 側のバッファも読み直す
      watch = true,
      win = {
        -- エージェントは常に右の縦分割。terminal_tabs.lua の下ドック端末とは別枠
        layout = "right",
        split = { width = 80 },
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>ac", toggle("claude"), mode = { "n", "x" }, desc = "Claude Code (right panel)" },
    { "<leader>ax", toggle("codex"),  mode = { "n", "x" }, desc = "Codex (right panel)" },
    {
      -- extras 側の <leader>as は未インストールのツールも全部並べてしまうので、
      -- PATH にあるものだけに絞ったピッカーに差し替える
      "<leader>as",
      function() require("sidekick.cli").select({ filter = { installed = true } }) end,
      desc = "Select CLI (installed)",
    },
  },
}
