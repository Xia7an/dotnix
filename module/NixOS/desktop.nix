{ config, pkgs, ... }:

{
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    hyprland
    kitty
    waybar
    rofi-power-menu
    rofi-wayland
    wl-clipboard
    brightnessctl
    grim
    slurp
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}

