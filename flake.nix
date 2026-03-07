{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
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
    xremap-flake.url = "github:xremap/nix-flake";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-nix = {
      url = "github:momeemt/tmux-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, winapps, antigravity-nix, tmux-nix, quickshell, ... } : let
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
      pkgs-stable = import nixpkgs-stable{
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
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({ ... }: { nixpkgs.overlays = overlays; })
          inputs.xremap-flake.nixosModules.default
          ./Atropos.nix
          (
            {
              pkgs,
              pkgs-stable,
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
          config = {
            allowUnfree = true; # プロプライエタリなパッケージを許可
            permittedInsecurePackages = [
              "openssl-1.1.1w"
            ];
          };
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
          config = {
            allowUnfree = true; # プロプライエタリなパッケージを許可
            permittedInsecurePackages = [
              "openssl-1.1.1w"
            ];
          };
          overlays = overlays;
        };
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = import inputs.nixpkgs-stable {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = overlays;
          };
        };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
