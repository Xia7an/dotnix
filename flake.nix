{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, winapps, antigravity-nix, tmux-nix, nixos-wsl, ... }: let
    linuxSystems = [ "x86_64-linux" ];
    darwinSystems = [ "aarch64-darwin" ];
    allSystems = linuxSystems ++ darwinSystems;
    forLinuxSystem = nixpkgs.lib.genAttrs linuxSystems;


    unstablePackageOverlay = final: prev: let
      unstable = import nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };
    in {
      google-chrome = unstable.google-chrome;
      discord = unstable.discord;
      claude-code = unstable.claude-code;
      opencode = unstable.opencode;
      vscode = unstable.vscode;
      vscode-utils = unstable.vscode-utils;
      vscode-extensions = unstable.vscode-extensions;
      zed-editor = unstable.zed-editor;
      obsidian = unstable.obsidian;
      slack = unstable.slack;
      vivaldi = unstable.vivaldi;
      nextcloud-client = unstable.nextcloud-client;
      neovim = unstable.neovim;
      blender = unstable.blender;
      rstudio = unstable.rstudio;
      noctalia = unstable.noctalia;
    };

    linuxOverlays = [
      (import inputs.rust-overlay)
      unstablePackageOverlay
    ];

    darwinOverlays = [
      (import inputs.rust-overlay)
      unstablePackageOverlay
    ];

    overlaysFor = system:
      if builtins.elem system darwinSystems then darwinOverlays else linuxOverlays;

    mkPkgs = import ./lib/mk-pkgs.nix;
    mkNixos = import ./lib/mk-nixos.nix;
    mkNixosWsl = import ./lib/mk-nixos-wsl.nix;
    mkDarwin = import ./lib/mk-darwin.nix;
    mkHome = import ./lib/mk-home.nix;

    pkgsFor = system: mkPkgs {
      inherit nixpkgs system;
      overlays = overlaysFor system;
    };

    pkgs-unstable-for = system: import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations = {
      Nyx = mkNixos {
        inherit inputs;
        hostPath = ./hosts/Nyx/system.nix;
        system = "x86_64-linux";
        overlays = linuxOverlays;
      };

      Atropos = mkNixos {
        inherit inputs;
        hostPath = ./hosts/Atropos/system.nix;
        system = "x86_64-linux";
        overlays = linuxOverlays;
        extraModules = [ inputs.xremap-flake.nixosModules.default ];
      };

      Anemoi = mkNixos {
        inherit inputs;
        hostPath = ./hosts/Anemoi/system.nix;
        system = "x86_64-linux";
        overlays = linuxOverlays;
        extraModules = [ inputs.xremap-flake.nixosModules.default ];
      };

      Clotho = mkNixosWsl {
        inherit inputs;
        hostPath = ./hosts/Clotho/system.nix;
        system = "x86_64-linux";
        overlays = linuxOverlays;
        extraModules = [ nixos-wsl.nixosModules.default ];
      };
    };

    darwinConfigurations = {
      Lachesis = mkDarwin {
        inherit inputs;
        hostPath = ./hosts/Lachesis/system.nix;
        system = "aarch64-darwin";
        overlays = darwinOverlays;
      };
    };

    homeConfigurations = {
      NyxHome = mkHome {
        inherit inputs;
        hostPath = ./hosts/Nyx/home.nix;
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable-for "x86_64-linux";
        };
      };

      AtroposHome = mkHome {
        inherit inputs;
        hostPath = ./hosts/Atropos/home.nix;
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable-for "x86_64-linux";
        };
      };

      AnemoiHome = mkHome {
        inherit inputs;
        hostPath = ./hosts/Anemoi/home.nix;
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable-for "x86_64-linux";
        };
      };

      ClothoHome = mkHome {
        inherit inputs;
        hostPath = ./hosts/Clotho/home.nix;
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable-for "x86_64-linux";
        };
      };

      LachesisHome = mkHome {
        inherit inputs;
        hostPath = ./hosts/Lachesis/home.nix;
        pkgs = pkgsFor "aarch64-darwin";
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable-for "aarch64-darwin";
        };
      };
    };
  };
}
