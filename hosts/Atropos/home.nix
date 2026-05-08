# Atropos ホスト固有の Home Manager 設定
{ ... }:
{
  imports = [
    ../../home.nix
    ./apps.nix
    ./desktop.nix
    ./develop.nix
    ./terminal.nix
    ../../module/Home/input
    ../../module/Home/windows
  ];

  home = {
    username = "inoyu";
    homeDirectory = "/home/inoyu";
    stateVersion = "25.11";
  };
}
