{ inputs }:
{
  Anemoi = {
    kind = "nixos";
    system = "x86_64-linux";
    systemModule = ./Anemoi/system.nix;
    homeModule = ./Anemoi/home.nix;
    homeDirectory = "/home/inoyu";
    homeStateVersion = "25.11";
    extraSystemModules = [ ];
  };

  Atropos = {
    kind = "nixos";
    system = "x86_64-linux";
    systemModule = ./Atropos/system.nix;
    homeModule = ./Atropos/home.nix;
    homeDirectory = "/home/inoyu";
    homeStateVersion = "25.11";
    extraSystemModules = [ inputs.xremap-flake.nixosModules.default ];
  };

  Clotho = {
    kind = "nixos";
    system = "x86_64-linux";
    systemModule = ./Clotho/system.nix;
    homeModule = ./Clotho/home.nix;
    homeDirectory = "/home/inoyu";
    homeStateVersion = "25.11";
    extraSystemModules = [ inputs.nixos-wsl.nixosModules.default ];
  };

  Lachesis = {
    kind = "darwin";
    system = "aarch64-darwin";
    systemModule = ./Lachesis/system.nix;
    homeModule = ./Lachesis/home.nix;
    homeDirectory = "/Users/inoyu";
    homeStateVersion = "25.11";
    extraSystemModules = [ ];
  };

  Nyx = {
    kind = "nixos";
    system = "x86_64-linux";
    systemModule = ./Nyx/system.nix;
    homeModule = ./Nyx/home.nix;
    homeDirectory = "/home/inoyu";
    homeStateVersion = "25.11";
    extraSystemModules = [ ];
  };
}
