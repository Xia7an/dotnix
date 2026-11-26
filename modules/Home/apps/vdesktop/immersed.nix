# Immersed (Linux 専用)
{ pkgs, ... }:
let
  # nixpkgs の immersed (linux.nix) は appimageTools.wrapAppImage に multiArch = true を渡しており、
  # FHS 環境に i686 版のライブラリ一式 (curl, fuse, onetbb ...) を引き込む。
  # i686-linux は cache.nixos.org にほぼ無く全部ソースビルドになるため、multiArch を無効化する。
  # (immersed 本体は 64bit アプリなので 32bit ライブラリは不要)
  appimageTools = pkgs.appimageTools // {
    wrapAppImage = args: pkgs.appimageTools.wrapAppImage (args // { multiArch = false; });
  };

  # package.nix は callPackage ./linux.nix で appimageTools を pkgs から取るため、
  # package.nix の callPackage 引数を差し替えて linux.nix に上の appimageTools を渡す。
  immersed = pkgs.immersed.override {
    callPackage = fn: args: pkgs.callPackage fn (args // { inherit appimageTools; });
  };
in
{
  home.packages = [ immersed ];
}
