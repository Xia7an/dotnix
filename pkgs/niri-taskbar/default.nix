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
  version = "v0.4.0+niri.25.11";

  src = fetchFromGitHub {
    owner = "lawngnome";
    repo = "niri-taskbar";
    rev = version;
    sha256 = "aE5v94AA6bC0CP8pv/SPBxGKpkH+GxR/p7hTKXlvk3E=";
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
