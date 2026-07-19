{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;

    settings = {
      # OpenCode のプラグイン設定
      # 現行名は oh-my-openagent、旧名 oh-my-opencode も互換あり
      plugin = [
        "oh-my-openagent@latest"
      ];
    };
  };
}
