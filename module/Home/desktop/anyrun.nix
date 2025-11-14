{ lib, pkgs, config, inputs, ... }: {
  # anyrunの代わりにwofiを使用（より安定）
  home.packages = with pkgs; [
    wofi
  ];
  
  # wofiの設定
  xdg.configFile."wofi/config".text = ''
    width=800
    height=400
    location=center
    show=drun
    prompt=Search...
    filter_rate=100
    allow_markup=true
    no_actions=true
    halign=fill
    orientation=vertical
    content_halign=fill
    insensitive=true
    allow_images=true
    image_size=40
    gtk_dark=true
  '';
  
  # wofiのスタイル（既存のanyrunスタイルを参考に）
  xdg.configFile."wofi/style.css".source = ../../../config/anyrun/style.css;
}
