{ inputs, hostPath, pkgs, extraSpecialArgs ? { }, extraModules ? [ ] }:
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit inputs; } // extraSpecialArgs;
  modules = extraModules ++ [ hostPath ];
}
