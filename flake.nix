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
    #anyrun = {
    #  url = "github:anyrun-org/anyrun";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    stock-ticker.url = "github:clundin55/stock-ticker";
  };

  outputs = inputs@{ nixpkgs, home-manager, stock-ticker, ... } : {
    nixosConfigurations = {
      Nyx = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./Nyx.nix
        ];
      };
      Atropos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86-64-linux";
        specialArgs = {
          stock-ticker = stock-ticker.packages."x86_64-linux".default;
        };
        modules = [
          ./Atropos.nix
        ];
      };
    };
    homeConfigurations = {
      NyxHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true; # プロプライエタリなパッケージを許可
          overlays = [(import inputs.rust-overlay)];
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
          overlays = [(import inputs.rust-overlay)];
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
