{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, winapps, ... } : let
    systems = [ "x86_64-linux" ];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    niriTaskbarOverlay = import ./overlays;
    overlays = [
      (import inputs.rust-overlay)
      niriTaskbarOverlay
    ];
  in {
    overlays.default = niriTaskbarOverlay;

    packages = forEachSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = overlays;
      };
    in {
      niri-taskbar = pkgs.niri-taskbar;
      default = pkgs.niri-taskbar;
    });

    nixosConfigurations = {
      Nyx = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ ... }: { nixpkgs.overlays = overlays; })
          ./Nyx.nix
        ];
      };
      Atropos = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86-64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({ ... }: { nixpkgs.overlays = overlays; })
          ./Atropos.nix
          (
            {
              pkgs,
              system ? pkgs.system,
              ...
            }:
            {
              environment.systemPackages = [
                winapps.packages."x86_64-linux".winapps
                winapps.packages."x86_64-linux".winapps-launcher # optional
              ];
            }
          )
        ];
      };
    };
    homeConfigurations = {
      NyxHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true; # プロプライエタリなパッケージを許可
          overlays = overlays;
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          ./home.nix
        ];
      };
      AtroposHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true; # プロプライエタリなパッケージを許可
          overlays = overlays;
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
