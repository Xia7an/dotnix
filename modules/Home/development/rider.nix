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
in
{
  home.packages = [
    rider
    # unityhub は NixOS モジュール (modules/NixOS/develop/unity.nix) がシステム全体に
    # overlay パッチ済み (libxml2 shim 含む) のものをインストールするため、
    # ここで再定義すると overlay の修正が失われて PATH で先に見つかる壊れた版が使われてしまう。
    # unityhub と unityhub-shell は NixOS 側に任せる。
    # (pkgs.callPackage ../packages/custom-unityhub.nix {})
  ];

  home.file.".local/share/JetBrains/Toolbox/apps/rider" = {
    source = "${rider}/rider";
    recursive = true;
  };
}