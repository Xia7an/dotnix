-- 右サイドの AI エージェントパネル (yetone/avante.nvim)。
--
-- ベースの spec と <leader>a* のキーマップは
-- lazyvim.plugins.extras.ai.avante (neovim.nix で import) が持っている。
-- ここではそこに載らない部分だけを上書きする。

return {
  {
    "yetone/avante.nvim",
    -- nixpkgs 版は Rust 製ライブラリ (lua/avante_*.dylib) をビルド済みで同梱しているので、
    -- extras 側が指定する `make` は走らせない (走らせると cargo とネットワークを要求する)
    build = false,
    opts = {
      -- extras の既定は copilot だが、ここでは Claude Code CLI を
      -- ACP (Agent Client Protocol) 経由で動かす。
      -- 認証は claude CLI 側 (~/.claude) のログインをそのまま使うので API キーは要らない。
      -- 起動には claude-agent-acp が PATH に必要 (neovim.nix の extraPackages)。
      provider = "claude-code",
      windows = {
        -- 常に右の縦分割。config/terminal_tabs.lua の下ドック端末とは別枠
        position = "right",
        width = 40,
      },
    },
  },

  -- 画像の貼り付け (avante/clipboard.lua が require する)。
  -- extras/ai/avante.lua 側の img-clip 設定は optional = true で、
  -- spec に載っているときだけ効くので、ここで明示的に載せる。
  { "HakonHarnes/img-clip.nvim" },
}
