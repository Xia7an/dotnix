{ config, pkgs, inputs, ... }: {
  imports = [
    ../common/nixos.nix
    ../../hardware/Nyx-hardware.nix
    ../../modules/NixOS/networkmanager.nix
    ../../modules/NixOS/desktop
    ../../modules/NixOS/desktop/sunshine.nix
    ../../modules/NixOS/system/bluetooth.nix
    ../../modules/NixOS/input/fcitx5.nix
  ];

  boot.loader.grub = {
    enable      = true;
    device      = "/dev/sda";
    useOSProber = true;
  };

  networking.hostName              = "Nyx";

  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ 22 ];
  };

  users.users.inoyu.extraGroups = [ "networkmanager" "wheel" ];

  fonts.packages = with pkgs; [
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    serif     = [ "Noto Serif CJK JP"   "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans CJK JP"    "Noto Color Emoji" ];
    monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
    emoji     = [ "Noto Color Emoji" ];
  };

  system.stateVersion = "25.05";
}
