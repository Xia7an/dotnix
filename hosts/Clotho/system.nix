{ config, pkgs, lib, inputs, ... }: {
  imports = [
    <nixos-wsl/modules>
  ];


  wsl.enable = true;
  wsl.defaultUser = "inoyu";

  networking.hostName              = "Clotho";

  system.stateVersion = "24.05";
}
