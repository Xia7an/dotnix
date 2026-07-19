{
  inputs,
  hosts,
  overlays,
}:
let
  inherit (inputs.nixpkgs) lib;

  username = "inoyu";
  supportedSystems = lib.unique (map (host: host.system) (lib.attrValues hosts));

  nixpkgsConfig = {
    allowUnfree = true;
  };

  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system overlays;
      config = nixpkgsConfig;
    };

  unstableFor =
    system:
    import inputs.nixpkgs-unstable {
      inherit system;
      config = nixpkgsConfig;
    };

  nixpkgsModule =
    system:
    { lib, ... }:
    {
      nixpkgs = {
        hostPlatform = lib.mkDefault system;
        inherit overlays;
        config = nixpkgsConfig;
      };
    };

  specialArgsFor = hostName: {
    inherit inputs hostName;
  };

  nixosHosts = lib.filterAttrs (_: host: host.kind == "nixos") hosts;
  darwinHosts = lib.filterAttrs (_: host: host.kind == "darwin") hosts;

  nixosConfigurations = lib.mapAttrs (
    hostName: host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgsFor hostName;
      modules = [ (nixpkgsModule host.system) ] ++ host.extraSystemModules ++ [ host.systemModule ];
    }
  ) nixosHosts;

  darwinConfigurations = lib.mapAttrs (
    hostName: host:
    inputs.darwin.lib.darwinSystem {
      specialArgs = specialArgsFor hostName;
      modules = [ (nixpkgsModule host.system) ] ++ host.extraSystemModules ++ [ host.systemModule ];
    }
  ) darwinHosts;

  homeConfigurations = lib.mapAttrs' (
    hostName: host:
    lib.nameValuePair "${hostName}Home" (
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor host.system;
        extraSpecialArgs = (specialArgsFor hostName) // {
          pkgs-unstable = unstableFor host.system;
        };
        modules = [
          ../home.nix
          {
            home = {
              inherit username;
              inherit (host) homeDirectory;
              stateVersion = host.homeStateVersion;
            };
          }
          host.homeModule
        ];
      }
    )
  ) hosts;
in
{
  inherit
    darwinConfigurations
    homeConfigurations
    nixosConfigurations
    pkgsFor
    supportedSystems
    ;
}
