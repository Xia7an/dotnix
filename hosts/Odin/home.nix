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
