{ pkgs, ... }: {
  # config/wofi をシンボリックリンクで配置
  home.file.".config/wofi" = {
    source = ../../../config/wofi;
    recursive = true;
  };

  # Wofi パッケージを home.packages に追加
  home.packages = with pkgs; [
    wofi
  ];
}
