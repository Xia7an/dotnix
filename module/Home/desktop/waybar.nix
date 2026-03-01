{ pkgs, ... }: {
  # config/waybar をシンボリックリンクで配置
  home.file.".config/waybar" = {
    source = ../../../config/waybar;
    recursive = true;
  };

  # Waybar パッケージを home.packages に追加
  home.packages = with pkgs; [
    waybar
    niri-taskbar
  ];
}
