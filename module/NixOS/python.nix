
{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.uv
  ];
}
