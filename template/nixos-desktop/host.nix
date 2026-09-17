{ ... }:
{
  kind = "nixos";
  system = "__SYSTEM__";
  username = "__USER_NAME__";
  systemModule = ./system.nix;
  homeModule = ./home.nix;
  homeDirectory = "__HOME_DIRECTORY__";
  homeStateVersion = "25.11";
  extraSystemModules = [ ];
}
