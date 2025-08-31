# ~/.config/home-manager/steam.nix
# SteamとProton-GEを管理するための最終的な設定

{ pkgs, ... }:

{
  # Steamなどのプロプライエタリなパッケージを許可
  nixpkgs.config.allowUnfree = true;

  # Steamをhome-managerの専用オプションで管理
  programs.steam = {
    enable = true;
    
    # このオプションがProton-GEを自動的に展開し、正しい場所に配置します
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };
}
