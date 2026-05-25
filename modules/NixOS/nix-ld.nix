{ pkgs, ... }: {
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    curl
    libffi
    ncurses
    libuuid
    icu
    xz
    sqlite
    readline
  ];
}
