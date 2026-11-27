# Odin: NixOS + Hyprland (AeroSpace 風の floating 運用) + RTX 2070 Super
{
  config,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/NixOS/locale.nix
    ../../modules/NixOS/fonts.nix
    ../../modules/NixOS/users.nix
    ../../modules/NixOS/packages.nix
    ../../modules/NixOS/nix.nix
    ../../modules/NixOS/git.nix
    ../../modules/NixOS/security.nix
    ../../modules/NixOS/nix-ld.nix
    ../../modules/NixOS/networkmanager.nix
    ../../modules/NixOS/services/openssh.nix
    ../../modules/NixOS/services/tailscale.nix
    ../../modules/NixOS/system/bluetooth.nix
    ../../modules/NixOS/input/fcitx5.nix
    ../../modules/NixOS/desktop/gdm.nix
    ../../modules/NixOS/desktop/nvidia.nix
    ../../modules/NixOS/desktop/hyprland-aerogrid.nix
  ];

  # UEFI + systemd-boot。インストール時のディスク構成に合わせて変更する。
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Odin";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  users.users.${username}.extraGroups = [
    "networkmanager"
    "wheel"
  ];

  # Magic Keyboard は US 配列 (Lachesis の入力ソースも ABC)。fcitx5 モジュールの既定は JIS。
  i18n.inputMethod.fcitx5.settings.inputMethod = {
    "Groups/0"."Default Layout" = pkgs.lib.mkForce "us";
    "Groups/0/Items/0".Name = pkgs.lib.mkForce "keyboard-us";
  };

  system.stateVersion = "25.11";
}
