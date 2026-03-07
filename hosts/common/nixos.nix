# 全ホスト共通の NixOS 設定
# ハードウェア固有・ネットワーク固有の設定は各ホストの default.nix に記述すること
{ pkgs, ... }:
{
  # ───────────────────────────────────────────
  # タイムゾーン
  # ───────────────────────────────────────────
  time.timeZone = "Asia/Tokyo";

  # ───────────────────────────────────────────
  # ロケール設定
  # ───────────────────────────────────────────
  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT    = "ja_JP.UTF-8";
    LC_MONETARY       = "ja_JP.UTF-8";
    LC_NAME           = "ja_JP.UTF-8";
    LC_NUMERIC        = "ja_JP.UTF-8";
    LC_PAPER          = "ja_JP.UTF-8";
    LC_TELEPHONE      = "ja_JP.UTF-8";
    LC_TIME           = "ja_JP.UTF-8";
  };

  # ───────────────────────────────────────────
  # フォント (全ホスト共通パッケージ)
  # fontconfig.defaultFonts は各ホストで設定する
  # ───────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      hackgen-nf-font
    ];
    fontDir.enable = true;
  };

  # ───────────────────────────────────────────
  # X11 / キーボードレイアウト
  # ───────────────────────────────────────────
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout  = "jp";
    variant = "";
  };

  # ───────────────────────────────────────────
  # ディスプレイマネージャー
  # ───────────────────────────────────────────
  services.displayManager.gdm.enable = true;

  # ───────────────────────────────────────────
  # ユーザー設定 (共通部分)
  # extraGroups は各ホストで users.users.inoyu.extraGroups として追加する
  # ───────────────────────────────────────────
  users.users.inoyu = {
    isNormalUser = true;
    description  = "Inoyu";
    shell        = pkgs.fish;
    packages     = [];
  };
  services.getty.autologinUser = "inoyu";
  programs.fish.enable = true;

  # ───────────────────────────────────────────
  # 共通システムパッケージ
  # ───────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim      # 設定変更時の緊急エディタ
    wget
    eza
    bat
    ripgrep
  ];

  # ───────────────────────────────────────────
  # 共通サービス
  # ───────────────────────────────────────────
  services.openssh.enable   = true;
  services.tailscale.enable = true;
  programs.git.enable       = true;

  # ───────────────────────────────────────────
  # Nix 設定
  # ───────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  # openssl_1_1 は EOL だが Unity Editor の内蔵 .NET ランタイムが
  # libssl.so.1.1 を要求するため unityhub-shell の FHS env で必要。
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters          = [ "https://hyprland.cachix.org" ];
    trusted-substituters  = [ "https://hyprland.cachix.org" ];
    trusted-public-keys   = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
