# Hyprland + noctalia + Quickshell で Lachesis のデスクトップ (AeroSpace の floating 運用、
# Hammerspoon の Option+Tab グリッド、alt-tab-macos、Raycast) を再現する。
#
# 設定本体はリポジトリのファイルを Nix store に取り込んで配置する (リポジトリの置き場所に依存しない)。
# 編集後は home-manager switch で反映する (Hyprland は switch 時に再読込される):
#   config/hypr/aerogrid/        Hyprland (キー、ルール、起動するもの)
#   config/noctalia/config.toml  noctalia (バー、ランチャー、通知、壁紙、画面ロック、Command+Tab)
#   config/quickshell/aerogrid/  AeroGrid (Option+Tab のグリッド、ウィンドウ配置)
# Hyprland 本体はシステム側 (modules/NixOS/desktop/hyprland-aerogrid.nix) で入れる。
{ lib, pkgs, ... }:
let
  hyprConfig = ../../../../config/hypr/aerogrid;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # NixOS の programs.hyprland が入れた本体とポータルを使う。
    package = null;
    portalPackage = null;
    # hyprland-session.target を用意し、ユーザーサービスがセッションに乗れるようにする。
    systemd.enable = true;
    # store のパスを直接読むので、設定を変えると hyprland.conf も変わり、switch 時に再読込される。
    extraConfig = ''
      source = ${hyprConfig}/hyprland.conf
      # nwg-displays (GUI) で決めたモニタ配置。Nix 管理外の書き込み可能なファイルで、
      # aerogrid の `monitor = , preferred, auto, 1` より後に読むので、こちらが優先される。
      source = ~/.config/hypr/monitors.conf
    '';
  };

  # monitors.conf が無いと Hyprland が source のエラーを出すので、空ファイルを用意しておく。
  home.activation.hyprMonitorsConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/hypr"
    [ -e "$HOME/.config/hypr/monitors.conf" ] || run touch "$HOME/.config/hypr/monitors.conf"
  '';

  # マウスカーソル。XCURSOR_* と HYPRCURSOR_* の env、GTK の設定、X11 アプリ用の設定をまとめて出す。
  # 見た目は name (Bibata-Modern-Classic: 黒 / Bibata-Modern-Ice: 白 / Bibata-Modern-Amber: 橙)、
  # 大きさは size で変える。bibata-cursors はキャッシュあり。
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };

  xdg.configFile."hypr/aerogrid".source = hyprConfig;
  xdg.configFile."noctalia/config.toml".source = ../../../../config/noctalia/config.toml;
  xdg.configFile."quickshell/aerogrid".source = ../../../../config/quickshell/aerogrid;

  home.packages = with pkgs; [
    # noctalia v5 は nixpkgs unstable にだけある (安定版の 25.11 には無い)。キャッシュあり。
    unstable.noctalia
    quickshell
    # モニタ配置の GUI エディタ。~/.config/hypr/monitors.conf に書き出す。
    nwg-displays
    wl-clipboard
    grim
    slurp
    # Fn+F7〜F9 のメディア操作
    playerctl
  ];
}
