{ ... }:
{
  imports = [
    ../../home.nix
    ./profile.nix
    ../../modules/Home/input
    ../../modules/Home/virtualization
  ];

  home = {
    username = "inoyu";
    homeDirectory = "/home/inoyu";
    stateVersion = "25.11";
  };
}
