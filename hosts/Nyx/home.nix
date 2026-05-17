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
