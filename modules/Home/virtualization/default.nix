# Virtualization modules
{ ... }: {
  imports = [
    ./docker.nix
    ./lima.nix
    ./qemu.nix
    ./winapps.nix
    ./bottles.nix
    ./winboat.nix
  ];
}
