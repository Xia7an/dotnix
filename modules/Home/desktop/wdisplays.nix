{ config, pkgs, ... }:

{  # パッケージの追加
  home.packages = with pkgs; [
    wdisplays # GUIディスプレイ配置ツール
    # 必要に応じて他のツールもここに追加
  ];
}
