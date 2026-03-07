# Nyx ホスト固有の NixOS 設定
# 共通設定は hosts/common/nixos.nix に記述されている
# アプリケーション・サービスの設定は module/NixOS/ 以下の各モジュールで管理する
{ config, pkgs, inputs, ... }:
{
  imports = [
    # 共通 NixOS 設定
    ../common/nixos.nix

    # ハードウェア設定
    ../../hardware/Nyx-hardware.nix

    # 機能モジュール (module/NixOS/ 以下)
    ../../module/NixOS/desktop
    ../../module/NixOS/system
  ];

  # ───────────────────────────────────────────
  # ブートローダー
  # ───────────────────────────────────────────
  boot.loader.grub = {
    enable      = true;
    device      = "/dev/sda";
    useOSProber = true;
  };

  # ───────────────────────────────────────────
  # ネットワーク設定 (Nyx 固有 — NetworkManager)
  # ───────────────────────────────────────────
  networking.hostName              = "Nyx";
  networking.networkmanager.enable = true;

  # ───────────────────────────────────────────
  # ファイアウォール
  # ───────────────────────────────────────────
  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000;  to = 8010;  }
    ];
    allowedUDPPorts  = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  # ───────────────────────────────────────────
  # ユーザー追加設定 (Nyx 固有グループ)
  # ───────────────────────────────────────────
  users.users.inoyu.extraGroups = [ "networkmanager" "wheel" ];

  # ───────────────────────────────────────────
  # フォント (Nyx 固有の追加フォント)
  # ───────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    serif     = [ "Noto Serif CJK JP"   "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans CJK JP"    "Noto Color Emoji" ];
    monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
    emoji     = [ "Noto Color Emoji" ];
  };

  # ───────────────────────────────────────────
  # Nyx 固有サービス
  # ───────────────────────────────────────────
  services.sunshine = {
    enable    = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # ───────────────────────────────────────────
  # 入力メソッド (Nyx は fcitx5)
  # ───────────────────────────────────────────
  i18n.inputMethod = {
    enabled      = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  # ───────────────────────────────────────────
  # プログラム
  # ───────────────────────────────────────────
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
  };

  programs.zsh = {
    enable     = true;
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/.p10k.zsh
    '';
  };

  environment.systemPackages = with pkgs; [
    zsh-powerlevel10k
    sunshine
  ];

  system.stateVersion = "25.05";
}
