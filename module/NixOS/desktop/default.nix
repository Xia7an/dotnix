{ config, pkgs, ... }:

{
  imports = [
    ./udiskie.nix   # ストレージ自動マウント
    ./kdeconnect.nix
    ./niri.nix
    ./hyprland.nix
    ./apps.nix      # デスクトップアプリケーション群
    ./xremap.nix
  ];

  programs.ydotool.enable = true;

  # Wayland デスクトップ環境に必要なシステムパッケージ
  environment.systemPackages = with pkgs; [
    # Wayland ユーティリティ
    wl-clipboard
    grim
    slurp

    # デスクトップ環境コンポーネント
    hyprpaper
    swaynotificationcenter
    waybar
    wofi

    # メディア・ドキュメント
    mpv
    vlc
    mupdf
    geeqie
    playerctl

    # サウンド・ネットワーク管理 UI
    pavucontrol
    networkmanagerapplet

    # GTK / Python (Wayland スクリプト連携用)
    gobject-introspection
    gtk3
    python3
    python3Packages.pygobject3

    # ターミナルエミュレータ (デスクトップから起動できるようにシステムに登録)
    alacritty
    kitty
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable            = true;
    xdgOpenUsePortal  = true;
    extraPortals      = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };
}

