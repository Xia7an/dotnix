# Anemoi ホスト固有の NixOS 設定
# 共通設定は hosts/common/nixos.nix に記述されている
# アプリケーション・サービスの設定は module/NixOS/ 以下の各モジュールで管理する
{ config, pkgs, inputs, ... }:
{
  imports = [
    # 共通 NixOS 設定
    ../common/nixos.nix

    # ハードウェア設定
    ../../hardware/anemoi.nix
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
    # 機能モジュール (module/NixOS/ 以下)
    ../../module/NixOS/desktop
    ../../module/NixOS/development
    ../../module/NixOS/system
    ../../module/NixOS/apps
    ../../module/NixOS/windows
    ../../module/NixOS/input
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

  # Windows とのデュアルブートのためハードウェアクロックをローカル時刻に
  time.hardwareClockInLocalTime = true;

  # ───────────────────────────────────────────
  # 1. Surface 固有設定 (nixos-hardware を利用)
  # ───────────────────────────────────────────
  # microsoft-surface-common モジュールが提供するオプション:
  #   hardware.microsoft-surface.kernelVersion: "longterm"(デフォルト) or "stable"
  hardware.microsoft-surface.kernelVersion = "stable";

  # タッチスクリーン / Surface ペン (IPTSD) を有効化
  services.iptsd.enable = true;

  # ───────────────────────────────────────────
  # 3. ネットワーク設定 (NetworkManager)
  # ───────────────────────────────────────────
  networking.hostName = "Anemoi";
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    # 接続プロファイル名（SSIDと同じにすると分かりやすいです）
    "aterm-b43571-a" = {
      connection = {
        id = "aterm-b43571-a";
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        ssid = "aterm-b43571-a";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        # ※ psk をここに書かなければ、初回接続時にパスワードを要求します
      };
    };
  };

  # ───────────────────────────────────────────
  # 4. バッテリー・電源管理 (Noctalia/UPower)
  # ───────────────────────────────────────────
  # これを有効にすることで Noctalia がバッテリー情報を取得できるようになります
  services.upower.enable = true;
  
  # Surface の電源ボタン等の挙動を最適化
  services.logind.settings.Login.HandlePowerKey = "suspend";


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
    pciutils             # PCI デバイス確認
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
