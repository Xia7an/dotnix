{ config, lib, pkgs, ... }: {
  # This will install Discord PTB for all users of the system
  environment.systemPackages = with pkgs; [
    discord
  ];
}
