{ config, pkgs, ... }:

{
  
  programs.ydotool.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
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
#    rofi-screenshot
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}

