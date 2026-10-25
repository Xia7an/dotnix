{
  imports = [
    ./home-manager/applications.nix
    ./home-manager/development-tools.nix
    ./home-manager/editors.nix
    ./home-manager/macos-integration.nix
    ./home-manager/shell-and-command-line.nix
    ./home-manager/terminal-emulators.nix
  ];

  # flake 構成 (lib/mk-configurations.nix) の外で評価される nix-shell -p や
  # nix shell --impure nixpkgs#... でも unfree パッケージを使えるようにする。
  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.ghostty.settings = {
    font-size = 14;
    theme = "Catppuccin Macchiato";
    macos-titlebar-style = "tabs";
    background-opacity = 0.92;
  };
}
