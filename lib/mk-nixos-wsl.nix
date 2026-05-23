{ inputs, hostPath, system, overlays, extraModules ? [ ] }:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules =
    [ ({ ... }: { nixpkgs.overlays = overlays; }) ]
    ++ extraModules
    ++ [ inputs.nixos-wsl.nixosModules.default ]
    ++ [ hostPath ];
}
