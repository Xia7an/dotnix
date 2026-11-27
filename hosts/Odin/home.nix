{
  imports = [
    ./home-manager/applications.nix
    ./home-manager/desktop-environment.nix
    ./home-manager/development-tools.nix
    ./home-manager/editors.nix
    ./home-manager/shell-and-command-line.nix
    ./home-manager/terminal-emulators.nix
    ../../modules/Home/input/karukan.nix
  ];

  # アドオン本体は NixOS 側 (hosts/Odin/system.nix) で fcitx5 に追加している。
  # ここではシステム辞書 (と必要なら config.toml) だけ配置する。
  programs.karukan = {
    enable = true;
    addToFcitx5Addons = false;
    # ~/.config/karukan-im/config.toml
    # 項目は https://github.com/togatoga/karukan/blob/main/docs/configuration.md
    settings = {
      # ライブ変換を起動時に無効にする (実行中は Ctrl+Shift+L で切り替えられる)
      conversion.live_conversion = false;
      # 変換学習を無効にする (学習データは ~/.local/share/karukan-im/learning.tsv)
      learning.enabled = false;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.ghostty.settings = {
    font-size = 14;
    theme = "Catppuccin Macchiato";
    background-opacity = 0.92;
  };
}
