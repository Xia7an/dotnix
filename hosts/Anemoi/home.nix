# Anemoi ホスト固有の Home Manager 設定
{ ... }:
{
  imports = [
    ../../home.nix
    ./profile.nix
    ../../modules/Home/input
    ../../modules/Home/windows
  ];

  home = {
    username = "inoyu";
    homeDirectory = "/home/inoyu";
    stateVersion = "25.11";
  };
}
