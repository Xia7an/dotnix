{ ... }:
{
  imports = [
    ./apps.nix
    ./desktop.nix
    ./dev.nix
    ./editor.nix
    ./shell.nix
    ./terminal.nix
    ./virtualization.nix
  ];

  home = {
    username = "inoyu";
    homeDirectory = "/home/inoyu";
    stateVersion = "25.11";
  };
}
