{ inputs, hostPath, system, overlays, extraModules ? [ ] }:
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules =
    [ ({ ... }: { nixpkgs.overlays = overlays; }) ]
    ++ extraModules
    ++ [ hostPath ];
}
