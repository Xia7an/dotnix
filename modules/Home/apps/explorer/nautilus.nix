{ pkgs, ... }: {
  home.packages = with pkgs; [ nautilus gnome-text-editor sushi ];
}
