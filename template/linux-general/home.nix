{ pkgs, ... }:
{
  targets.genericLinux = {
    enable = true;
    gpu.enable = pkgs.stdenv.hostPlatform.isx86_64;
  };

  imports = [
    ./home-manager/applications.nix
    ./home-manager/development-tools.nix
    ./home-manager/editors.nix
    ./home-manager/shell-and-command-line.nix
    ./home-manager/terminal-emulators.nix
  ];

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
