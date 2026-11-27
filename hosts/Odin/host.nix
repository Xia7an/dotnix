{ ... }:
{
  kind = "nixos";
  system = "x86_64-linux";
  username = "inoyu";
  systemModule = ./system.nix;
  homeModule = ./home.nix;
  homeDirectory = "/home/inoyu";
  homeStateVersion = "25.11";
  extraSystemModules = [ ];
}
