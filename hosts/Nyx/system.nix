{ config, pkgs, inputs, ... }: {
  imports = [
    ../../hardware/Nyx-hardware.nix
    ../../modules/NixOS/locale.nix
    ../../modules/NixOS/fonts.nix
    ../../modules/NixOS/users.nix
    ../../modules/NixOS/packages.nix
    ../../modules/NixOS/nix.nix
    ../../modules/NixOS/git.nix
    ../../modules/NixOS/services/openssh.nix
    ../../modules/NixOS/services/tailscale.nix
  ];

  boot.loader.grub = {
    enable      = true;
    device      = "/dev/sda";
    useOSProber = true;
  };

  networking.hostName = "Nyx";

  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ 22 ];
  };

  users.users.inoyu.extraGroups = [ "networkmanager" "wheel" ];

  system.stateVersion = "25.05";
}
