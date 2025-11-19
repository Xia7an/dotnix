{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk3
, glib
, pango
, cairo
, gdk-pixbuf
, atk
, gobject-introspection
}:

rustPlatform.buildRustPackage rec {
  pname = "niri-taskbar";
  version = "0.3.0+niri.25.08-unstable-2025-09-19";

  src = fetchFromGitHub {
    owner = "lawngnome";
    repo = "niri-taskbar";
    rev = "874ed92a1711422bcaaf635c7c3316edfc6a9d31";
    hash = "sha256-P1ZD1cxlU/0s73h7qHGCbV29fsAt6r4+9X4PEZ+mOiM=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    pango
  ];

  meta = with lib; {
    description = "Waybar taskbar module tailored for the Niri Wayland compositor";
    homepage = "https://github.com/lawngnome/niri-taskbar";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
