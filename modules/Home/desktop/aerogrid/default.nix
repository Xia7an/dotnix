# Hyprland + noctalia + Quickshell で Lachesis のデスクトップ (AeroSpace の floating 運用、
# Hammerspoon の Option+Tab グリッド、alt-tab-macos、Raycast) を再現する。
#
# 設定本体はリポジトリのファイルを Nix store に取り込んで配置する (リポジトリの置き場所に依存しない)。
# 編集後は home-manager switch で反映する (Hyprland は switch 時に再読込される):
#   config/hypr/aerogrid/        Hyprland (キー、ルール、起動するもの)
#   config/noctalia/config.toml  noctalia (バー、ランチャー、通知、壁紙、画面ロック、Command+Tab)
#   config/quickshell/aerogrid/  AeroGrid (Option+Tab のグリッド、ウィンドウ配置)
# Hyprland 本体はシステム側 (modules/NixOS/desktop/hyprland-aerogrid.nix) で入れる。
{ pkgs, ... }:
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
    '';
  };

  xdg.configFile."hypr/aerogrid".source = hyprConfig;
  xdg.configFile."noctalia/config.toml".source = ../../../../config/noctalia/config.toml;
  xdg.configFile."quickshell/aerogrid".source = ../../../../config/quickshell/aerogrid;

  home.packages = with pkgs; [
    # noctalia v5 は nixpkgs unstable にだけある (安定版の 25.11 には無い)。キャッシュあり。
    unstable.noctalia
    quickshell
    wl-clipboard
    grim
    slurp
  ];
}
