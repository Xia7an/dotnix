{ config, pkgs, ... }:

{
  imports = [
    ./udiskie.nix
    ./nautilus.nix
    ./thunderbird.nix
    ./kdeconnect.nix
    ./niri.nix
    ./apps.nix
  ];
  
  programs.ydotool.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    gobject-introspection
    gtk3
    python3
    python3Packages.pygobject3
    alacritty
    wofi

    hyprland
    kitty
    waybar
    mpv
    playerctl
    anyrun
#    rofi-power-menu
#    rofi-wayland
    wl-clipboard
    swaynotificationcenter
    hyprpaper
    grim
    slurp
    mupdf
    vlc
    geeqie
    networkmanagerapplet
    pavucontrol
#    rofi-screenshot
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}

