# Input method modules
# fcitx5 は Linux/Wayland 向け。macOS ではスキップする
{ ... }: {
  imports = [ ./fcitx5.nix
    # ./ibus.nix  # Alternative to Fcitx5
  ];
}
