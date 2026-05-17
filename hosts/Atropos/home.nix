# Atropos ホスト固有の Home Manager 設定
{ ... }:
{
  imports = [
    ../../home.nix
    ./profile.nix
    ../../modules/Home/input
  ];

  home = {
    username = "inoyu";
    homeDirectory = "/home/inoyu";
    stateVersion = "25.11";
  };
}
