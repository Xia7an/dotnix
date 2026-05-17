{ config, pkgs, ... }:

{
  imports = [
    ./udiskie.nix   # ストレージ自動マウント
    ./kdeconnect.nix
    ./niri.nix
    ./hyprland.nix
    ./xremap.nix
  ];

  programs.ydotool.enable = true;

  # Wayland デスクトップ環境に必要なシステムレベルの依存関係
  environment.systemPackages = with pkgs; [
    # GTK / Python (Wayland スクリプト連携用)
    gobject-introspection
    gtk3
    python3
    python3Packages.pygobject3
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable            = true;
    xdgOpenUsePortal  = true;
    extraPortals      = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };
}
