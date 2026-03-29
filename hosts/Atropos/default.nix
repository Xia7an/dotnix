# Atropos ホスト固有の NixOS 設定
# 共通設定は hosts/common/nixos.nix に記述されている
# アプリケーション・サービスの設定は module/NixOS/ 以下の各モジュールで管理する
{ config, pkgs, inputs, ... }:
{
  imports = [
    # 共通 NixOS 設定
    ../common/nixos.nix

    # ハードウェア設定
    ../../hardware/Atropos-SSD-hardware.nix

    # 機能モジュール (module/NixOS/ 以下)
    ../../module/NixOS/desktop
    ../../module/NixOS/development
    ../../module/NixOS/system
    ../../module/NixOS/apps
    ../../module/NixOS/windows
    ../../module/NixOS/input

    # Atropos 固有モジュール (Anemoi にはインストールしない)
    ../../module/NixOS/development/unity.nix
    ../../module/NixOS/apps/gaming.nix
    ../../module/NixOS/windows/winboat.nix
    ../../module/NixOS/system/docker-nvidia.nix
    ../../module/NixOS/system/wine.nix
  ];

  # ───────────────────────────────────────────
  # ブートローダー
  # ───────────────────────────────────────────
  boot.loader.grub = {
    enable              = true;
    device              = "nodev";
    useOSProber         = true;
    efiSupport          = true;
    efiInstallAsRemovable = true;
    theme               = ../../misc/Vimix;
  };
  # Ensure NVIDIA kernel modules are loaded early so the GPU has a driver
  # bound to it. This helps avoid "driver (null)" and EGL/DRI errors.
  boot.kernelModules      = [ "kvm-intel" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.supportedFilesystems = [ "ntfs" ]; # Windows デュアルブート用

  # Windows とのデュアルブートのためハードウェアクロックをローカル時刻に
  time.hardwareClockInLocalTime = true;

  # ───────────────────────────────────────────
  # NVIDIA GPU 設定 (Atropos 固有)
  # ───────────────────────────────────────────
  hardware.opengl = {
    enable         = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable             = true;
    powerManagement.enable         = false;
    powerManagement.finegrained    = false;
    open                           = true; # Turing 世代以降
    forceFullCompositionPipeline   = true;
  };

  # ───────────────────────────────────────────
  # ネットワーク設定 (Atropos 固有 — 静的 IP + wpa_supplicant)
  # ───────────────────────────────────────────
  networking.hostName           = "Atropos";
  networking.networkmanager.enable = false;
  networking.useNetworkd        = true;
  networking.interfaces."wlp3s0".ipv4.addresses = [{
    address      = "192.168.10.10";
    prefixLength = 24;
  }];
  networking.defaultGateway = {
    interface = "wlp3s0";
    address   = "192.168.10.1";
  };
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  networking.wireless = {
    enable      = true;
    secretsFile = "/home/inoyu/secrets/wireless.conf";
    networks."aterm-b43571-a".pskRaw = "ext:psk";
  };

  # ───────────────────────────────────────────
  # ファイアウォール
  # ───────────────────────────────────────────
  networking.firewall = {
    enable           = true;
    allowedTCPPorts  = [ 22 3389 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000;  to = 8010;  }
    ];
    allowedUDPPorts  = [ config.services.tailscale.port 3389 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  # ───────────────────────────────────────────
  # ユーザー追加設定 (Atropos 固有グループ)
  # ───────────────────────────────────────────
  users.users.inoyu.extraGroups =
    [ "networkmanager" "wheel" "docker" "storage" ];

  # パスワード不要の sudo (開発用途)
  security.sudo = {
    enable = true;
    extraRules = [{
      users    = [ "inoyu" ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }];
  };

  # 自動ログイン
  services.displayManager.autoLogin = { enable = true; user = "inoyu"; };

  # ───────────────────────────────────────────
  # フォント (Atropos 固有の追加フォント)
  # ───────────────────────────────────────────
  fonts.packages = with pkgs; [
    twitter-color-emoji
    source-han-sans
    source-han-serif
    jetbrains-mono
    nerd-fonts._0xproto
    orbitron
    rounded-mgenplus
  ];
  fonts.fontconfig.defaultFonts = {
    serif     = [ "Noto Serif CJK JP"  "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans CJK JP"   "Noto Color Emoji" ];
    monospace = [ "HackGen Console NF" "Noto Color Emoji" ];
    emoji     = [ "Noto Color Emoji" ];
  };

  # ───────────────────────────────────────────
  # Atropos 固有パッケージ
  # ───────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vulkan-tools         # GPU 診断
    nvtopPackages.nvidia # GPU モニター
    pciutils             # PCI デバイス確認
    alcom                # AlterLinux Community Manager
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable     = true;
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/.p10k.zsh
    '';
  };

  system.stateVersion = "25.05";
}
