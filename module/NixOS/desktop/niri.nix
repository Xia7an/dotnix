{ config, pkgs, lib, ...}:
{
  programs.niri = {
    enable = true;
  };
  environment.systemPackages = [
    pkgs.xwayland-satellite
  ];
}
