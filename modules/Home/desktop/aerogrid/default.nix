# Hyprland + Quickshell で Lachesis のデスクトップ (AeroSpace の floating 運用、
# Hammerspoon の Option+Tab グリッド、alt-tab-macos、Raycast のウィンドウ配置) を再現する。
#
# 設定本体はリポジトリへ直接リンクするので、編集後は switch 不要:
#   config/hypr/aerogrid/       Hyprland (保存すると自動で再読込)
#   config/quickshell/aerogrid/ バー・グリッド・スイッチャー・配置 (保存すると自動で再読込)
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
    # hyprland-session.target を用意し、swww などのユーザーサービスを起動する。
    systemd.enable = true;
    extraConfig = ''
      source = ${config.xdg.configHome}/hypr/aerogrid/hyprland.conf
    '';
  };

  xdg.configFile."hypr/aerogrid".source = link "config/hypr/aerogrid";
  xdg.configFile."quickshell/aerogrid".source = link "config/quickshell/aerogrid";

  home.packages = with pkgs; [
    quickshell
    hyprpolkitagent
    wl-clipboard
    grim
    slurp
  ];
}
