{ pkgs, ... }: {
  home.packages = with pkgs; [ pavucontrol networkmanagerapplet ];
}
