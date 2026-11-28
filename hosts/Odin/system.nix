# Odin: NixOS + Hyprland (AeroSpace 風の floating 運用) + RTX 2070 Super
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/NixOS/locale.nix
    ../../modules/NixOS/fonts.nix
    ../../modules/NixOS/users.nix
    ../../modules/NixOS/packages.nix
    ../../modules/NixOS/nix.nix
    ../../modules/NixOS/git.nix
    ../../modules/NixOS/security.nix
    ../../modules/NixOS/nix-ld.nix
    ../../modules/NixOS/networkmanager.nix
    ../../modules/NixOS/services/openssh.nix
    ../../modules/NixOS/services/tailscale.nix
    ../../modules/NixOS/input/fcitx5.nix
    inputs.nix-hazkey.nixosModules.hazkey
    ../../modules/NixOS/desktop/gdm.nix
    ../../modules/NixOS/desktop/nvidia.nix
    ../../modules/NixOS/desktop/hyprland-aerogrid.nix
    ../../modules/NixOS/desktop/nautilus.nix
    ../../modules/NixOS/virtualisation/docker.nix
  ];

  # UEFI + systemd-boot。インストール時のディスク構成に合わせて変更する。
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ハイバネート: RAM (32GB) を書き出せるサイズのスワップファイルを用意する。
  # systemd initrd を使うと、systemd が EFI 変数 (HibernateLocation) に復帰先を記録するため
  # resume_offset をカーネルパラメータに書かずにスワップファイルから復帰できる。
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # MiB
    }
  ];
  boot.initrd.systemd.enable = true;
  # NVIDIA の VRAM をハイバネート/サスペンド時に退避・復元する (nvidia-hibernate.service 等)。
  hardware.nvidia.powerManagement.enable = lib.mkForce true;

  # キーボードは JIS 配列。TTY と GDM のログイン画面 (XKB の既定値を使う) も合わせる。
  # セッション内は Hyprland (config/hypr/aerogrid) と fcitx5 (modules/NixOS/input/fcitx5.nix) で設定している。
  console.keyMap = "jp106";
  services.xserver.xkb = {
    layout = "jp";
    model = "jp106";
  };

  # 日本語入力は hazkey (nix-hazkey) を既定にし、mozc も切り替え先として残す。
  # fcitx5 アドオン・hazkey-settings・hazkey-server (systemd ユーザーサービス) が入る。
  # Zenzai の有効化などの変換設定は hazkey-settings の GUI で行う。
  services.hazkey.enable = true;
  # nix-hazkey は default.target にしか紐付けないので、ユーザーマネージャーが
  # 生き残ったまま switch / 再ログインすると hazkey-server が起動せず、
  # fcitx5 側が接続を待ち続けて一切入力できなくなる。
  # グラフィカルセッション (Hyprland) の開始時にも必ず起動させる。
  systemd.user.services.hazkey-server.wantedBy = [ "graphical-session.target" ];
  i18n.inputMethod.fcitx5.settings.inputMethod = {
    "Groups/0".DefaultIM = lib.mkForce "hazkey";
    "Groups/0/Items/2".Name = "hazkey";
  };

  networking.hostName = "Odin";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  users.users.${username}.extraGroups = [
    "networkmanager"
    "wheel"
  ];

  system.stateVersion = "25.11";
}
