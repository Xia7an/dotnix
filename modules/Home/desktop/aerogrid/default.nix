# Hyprland + noctalia + Quickshell で Lachesis のデスクトップ (AeroSpace の floating 運用、
# Hammerspoon の Option+Tab グリッド、alt-tab-macos、Raycast) を再現する。
#
# 設定本体はリポジトリへ直接リンクするので、編集後は switch 不要 (保存すると各自が再読込する):
#   config/hypr/aerogrid/        Hyprland (キー、ルール、起動するもの)
#   config/noctalia/config.toml  noctalia (バー、ランチャー、通知、壁紙、画面ロック、Command+Tab)
#   config/quickshell/aerogrid/  AeroGrid (Option+Tab のグリッド、ウィンドウ配置)
# Hyprland 本体はシステム側 (modules/NixOS/desktop/hyprland-aerogrid.nix) で入れる。
{ config, pkgs, ... }:
let
  repo = "${config.home.homeDirectory}/Gits/dotnix";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # NixOS の programs.hyprland が入れた本体とポータルを使う。
    package = null;
    portalPackage = null;
    # hyprland-session.target を用意し、ユーザーサービスがセッションに乗れるようにする。
    systemd.enable = true;
    extraConfig = ''
      source = ${config.xdg.configHome}/hypr/aerogrid/hyprland.conf
    '';
  };

  xdg.configFile."hypr/aerogrid".source = link "config/hypr/aerogrid";
  xdg.configFile."noctalia/config.toml".source = link "config/noctalia/config.toml";
  xdg.configFile."quickshell/aerogrid".source = link "config/quickshell/aerogrid";

  home.packages = with pkgs; [
    # noctalia v5 は nixpkgs unstable にだけある (安定版の 25.11 には無い)。キャッシュあり。
    unstable.noctalia
    quickshell
    wl-clipboard
    grim
    slurp
  ];
}
