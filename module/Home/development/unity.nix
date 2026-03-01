{
  pkgs,
  lib,
  pkgs-stable,
  ...
}:
let
  extra-path = with pkgs; [
    # Add any extra binaries you want accessible to Rider here
    dotnet-sdk
  ];

  extra-lib = with pkgs; [
    # Add any extra libraries you want accessible to Rider here
  ];

  rider = pkgs.jetbrains.rider.overrideAttrs (attrs: {
    postInstall = ''
      # Wrap rider with extra tools and libraries
      mv $out/bin/rider $out/bin/.rider-toolless
      makeWrapper $out/bin/.rider-toolless $out/bin/rider \
        --argv0 rider \
        --prefix PATH : "${lib.makeBinPath extra-path}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}" \
        --set DISPLAY :0 \
        --set GTK_IM_MODULE fcitx \
        --set QT_IM_MODULE fcitx \
        --set XMODIFIERS @im=fcitx

      # Making Unity Rider plugin work!
      # The plugin expects the binary to be at /rider/bin/rider,
      # with bundled files at /rider/
      # It does this by going up two directories from the binary path
      # Our rider binary is at $out/bin/rider, so we need to link $out/rider/ to $out/
      shopt -s extglob
      ln -s $out/rider/!(bin) $out/
      shopt -u extglob
    ''
    + attrs.postInstall or "";
  });
  # Customized Unity Hub with extra dependencies for Unity Editors
  unityhub = pkgs.unityhub.override {
    extraLibs = pkgs: with pkgs; [
      # Common dependencies for Unity Editors
      openssl_1_1 # Often needed for older editors or hub login
      nss
      nspr
      cups
      libcap
      alsa-lib
      cairo
      pango
      gdk-pixbuf
      gtk3
      expat
      zlib
      libuuid
      libxml2
      libglvnd
      mesa
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXi
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXrender
      xorg.libXtst
      xorg.libXScrnSaver
      wayland
      icu
    ];
  };
in
{
  home.packages = [
    rider
    unityhub
    # (pkgs.callPackage ../packages/custom-unityhub.nix {})
  ];

  home.file.".local/share/JetBrains/Toolbox/apps/rider" = {
    source = "${rider}/rider";
    recursive = true;
  };
}