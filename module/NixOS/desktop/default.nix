{ config, pkgs, ... }:

{
  imports = [
    ./nautilus.nix
    ./thunderbird.nix
  ];
  
  programs.ydotool.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    gobject-introspection
    gtk3
    python3
    python3Packages.pygobject3


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

