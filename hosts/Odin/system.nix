# Odin: NixOS + Hyprland (AeroSpace 風の floating 運用) + RTX 2070 Super
{
  config,
  lib,
  pkgs,
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
    ../../modules/NixOS/system/bluetooth.nix
    ../../modules/NixOS/input/fcitx5.nix
    ../../modules/NixOS/input/karukan.nix
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

  # 日本語入力は karukan を既定にし、mozc も切り替え先として残す。
  # 辞書と config.toml は Home Manager 側 (hosts/Odin/home.nix) で配置している。
  programs.karukan.enable = true;
  i18n.inputMethod.fcitx5.settings.inputMethod = {
    "Groups/0".DefaultIM = lib.mkForce "karukan";
    "Groups/0/Items/2".Name = "karukan";
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
