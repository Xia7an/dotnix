final: prev: {
  niri-taskbar = prev.callPackage ../pkgs/niri-taskbar { };
  
  # Unity Hub Workaround: https://github.com/nixos/nixpkgs/issues/419634
  gnome2 = prev.gnome2 // {
    GConf = final.emptyDirectory;
  };
  unityhub = prev.unityhub.override {
    extraLibs = (unityhubPkgs: [
      (unityhubPkgs.runCommand "libxml2-fake-old-abi" {} ''
        mkdir -p "$out/lib"
        ln -s "${unityhubPkgs.lib.getLib unityhubPkgs.libxml2}/lib/libxml2.so" "$out/lib/libxml2.so.2"
      '')
    ]);
  };
}
