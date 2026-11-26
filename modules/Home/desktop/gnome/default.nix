# Ubuntu 24.04 (GNOME 46 / Mutter X11) で Lachesis の AeroSpace 運用を再現する。
# 詳細は docs/gnome-aerogrid.md。
{
  imports = [
    ./workspaces.nix
    ./keybindings.nix
    ./dock.nix
    ./aerogrid.nix
  ];
}
