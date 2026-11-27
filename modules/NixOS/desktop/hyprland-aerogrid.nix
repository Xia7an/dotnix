# Hyprland を AeroSpace 風の floating 運用で使うためのシステム側の設定。
# ユーザー側 (キー、ルール、Quickshell のバーとグリッド) は modules/Home/desktop/aerogrid/。
# パッケージはキャッシュのある nixpkgs 版 (flake input の hyprland は手元ビルドになるため使わない)。
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Electron / Chromium 系を Wayland で動かす。
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ファイル選択などは GTK のポータル、画面共有は Hyprland のポータル (programs.hyprland が追加)。
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # hyprlock で画面ロックを解除するための PAM。
  security.pam.services.hyprlock = { };
  security.polkit.enable = true;

  # 音声 (PipeWire)。
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
