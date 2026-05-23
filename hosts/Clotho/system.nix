{ config, pkgs, lib, inputs, ... }: {
  imports = [
    <nixos-wsl/modules>
    ../../modules/NixOS/locale.nix
    ../../modules/NixOS/fonts.nix
    ../../modules/NixOS/users.nix
    ../../modules/NixOS/packages.nix
    ../../modules/NixOS/nix.nix
    ../../modules/NixOS/git.nix
    ../../modules/NixOS/services/openssh.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "inoyu";

  networking.hostName = "Clotho";

  system.stateVersion = "24.05";
}
