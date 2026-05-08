{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, winapps, antigravity-nix, tmux-nix, quickshell, ... } : let
    linuxSystems = [ "x86_64-linux" ];
    darwinSystems = [ "aarch64-darwin" ];
    allSystems = linuxSystems ++ darwinSystems;
    forEachSystem = nixpkgs.lib.genAttrs allSystems;
    forLinuxSystem = nixpkgs.lib.genAttrs linuxSystems;

    niriTaskbarOverlay = import ./overlays;

    # Linux 向けオーバーレイ (niri-taskbar は Wayland/niri 依存)
    linuxOverlays = [
      (import inputs.rust-overlay)
      niriTaskbarOverlay
    ];

    # macOS 向けオーバーレイ (rust-overlay のみ)
    darwinOverlays = [
      (import inputs.rust-overlay)
    ];

    # pkgs インスタンスの共通設定 (システムごとに適切なオーバーレイを選択)
    mkPkgs = system: import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "openssl-1.1.1w" ];
      };
      overlays = if builtins.elem system darwinSystems then darwinOverlays else linuxOverlays;
    };

    # darwin ホストが参照する overlays (nix-darwin モジュール向け)
    # rust-overlay のみ (niri-taskbar は Wayland 依存のため除外)
    darwinNixpkgsOverlays = darwinOverlays;
  in {
    overlays.default = niriTaskbarOverlay;

    packages = forLinuxSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = linuxOverlays;
      };
    in {
      niri-taskbar = pkgs.niri-taskbar;
      default      = pkgs.niri-taskbar;
    });

    # ─────────────────────────────────────────
    # NixOS ホスト設定
    # 各ホストの詳細は hosts/<HostName>/default.nix を参照
    # ─────────────────────────────────────────
    nixosConfigurations = {
      Nyx = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ ... }: { nixpkgs.overlays = linuxOverlays; })
          ./hosts/Nyx
        ];
      };

      Atropos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ ... }: { nixpkgs.overlays = linuxOverlays; })
          inputs.xremap-flake.nixosModules.default
          ./hosts/Atropos
        ];
      };
      Anemoi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ ... }: { nixpkgs.overlays = linuxOverlays; })
          inputs.xremap-flake.nixosModules.default
          ./hosts/Anemoi
        ];
      };
    };

    # ─────────────────────────────────────────
    # macOS (nix-darwin) ホスト設定
    # 各ホストの詳細は hosts/<HostName>/default.nix を参照
    # ─────────────────────────────────────────
    darwinConfigurations = {
      Lachesis = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ({ ... }: { nixpkgs.overlays = darwinNixpkgsOverlays; })
          ./hosts/Lachesis
        ];
      };
    };

    # ─────────────────────────────────────────
    # Home Manager 設定
    # 共通設定: home.nix → module/Home/ 以下の各モジュール
    # ─────────────────────────────────────────
    homeConfigurations = {
      NyxHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/Nyx/home.nix ];
      };

      AtroposHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = import inputs.nixpkgs-stable {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = linuxOverlays;
          };
        };
        modules = [ ./hosts/Atropos/home.nix ];
      };
      AnemoiHome= inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = import inputs.nixpkgs-stable {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = linuxOverlays;
          };
        };
        modules = [ ./hosts/Anemoi/home.nix ];
      };
      LachesisHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "aarch64-darwin";
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = import inputs.nixpkgs-stable {
            system = "aarch64-darwin";
            config.allowUnfree = true;
            overlays = darwinOverlays;
          };
        };
        modules = [ ./hosts/Lachesis/home.nix ];
      };
    };
  };
}
