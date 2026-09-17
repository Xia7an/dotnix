{ pkgs, ... }: {
  # The stable package depends on Electron 39, which nixpkgs marks insecure.
  home.packages = with pkgs.unstable; [ bitwarden-desktop ];
}
