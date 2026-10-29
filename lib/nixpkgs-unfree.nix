# `nixpkgs` レジストリ用の flake (unfree 許可済み) を store に作る。
#
# flake の評価は純粋評価なので ~/.config/nixpkgs/config.nix や NIXPKGS_ALLOW_UNFREE は
# 読まれず、`nix run nixpkgs#<unfree>` は --impure なしでは失敗する。
# レジストリの nixpkgs をこの flake に向けることで、純粋評価のまま unfree が通る。
#
# 入力の nixpkgs は dotnix がロックしている store パスに固定するので、
# 追加のダウンロードは発生せず、システムと同じリビジョンが使われる。
# (入力を store パスで明示しないと `flake:nixpkgs` として解決され、レジストリが循環する)
{ pkgs, nixpkgs }:
let
  nixpkgsRef = {
    type = "path";
    path = nixpkgs.outPath;
  };

  flake = ''
    {
      description = "nixpkgs with allowUnfree = true";

      inputs.nixpkgs.url = "path:${nixpkgs.outPath}";

      outputs =
        { nixpkgs, ... }:
        {
          inherit (nixpkgs) lib nixosModules htmlDocs;

          legacyPackages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
            system:
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          );
        };
    }
  '';

  lock = {
    version = 7;
    root = "root";
    nodes = {
      root.inputs.nixpkgs = "nixpkgs";
      nixpkgs = {
        locked = nixpkgsRef // {
          inherit (nixpkgs) lastModified narHash;
        };
        original = nixpkgsRef;
      };
    };
  };
in
pkgs.runCommandLocal "nixpkgs-unfree-source" { } ''
  mkdir $out
  cp ${pkgs.writeText "flake.nix" flake} $out/flake.nix
  cp ${pkgs.writeText "flake.lock" (builtins.toJSON lock)} $out/flake.lock
''
