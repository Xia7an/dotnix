{
  config,
  pkgs,
  inputs,
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
    ../../modules/NixOS/services/openssh.nix
    ../../modules/NixOS/services/tailscale.nix
    ../../modules/NixOS/nix-ld.nix
  ];

  # Nyx と同じ GRUB 構成。別のディスクや UEFI 構成では適用前に変更する。
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking.hostName = "__HOST_NAME__";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  users.users.${username}.extraGroups = [
    "networkmanager"
    "wheel"
  ];

  system.stateVersion = "25.11";
}
