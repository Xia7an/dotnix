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
    # --- 今回のエラー（libgobject-2.0.so.0）を解決するパッケージ ---
  glib

  # --- 今後Electron/Chromiumで高確率で必要になる主要ライブラリ ---
  nss
  nspr
  atk
  at-spi2-atk
  cups
  dbus
  libdrm
  gdk-pixbuf
  gtk3
  pango
  cairo
  xorg.libX11
  xorg.libXcomposite
  xorg.libXdamage
  xorg.libXext
  xorg.libXfixes
  xorg.libXrandr
  xorg.libXrender
  xorg.libXtst
  xorg.libXxi
  xorg.libXScrnSaver
  xorg.libxcb
  libxkbcommon
  mesa
  alsa-lib
  expat
  udev
  ];
}
