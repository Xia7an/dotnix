# Lachesis ホスト固有の nix-darwin 設定
# macOS Sequoia 26.2 — Apple Silicon (aarch64-darwin) 用
# 最終目標: `darwin-rebuild switch` 一発でこのMacの環境を完全再現する
{ config, pkgs, inputs, lib, ... }: {
  imports = [ ];

  # ───────────────────────────────────────────
  # ホスト基本情報
  # ───────────────────────────────────────────
  networking.hostName = "Lachesis";
  time.timeZone = "Asia/Tokyo";

  # nix-darwin が system.defaults や homebrew を root として適用するために必要
  # 実ユーザーのユーザー名を指定
  system.primaryUser = "inoyu";

  # ───────────────────────────────────────────
  # Homebrew 自体の自動インストール
  # nix-darwin の homebrew モジュールは Homebrew が
  # インストール済みであることを前提としている。
  # この activation script は brew が存在しない場合に
  # 自動で Homebrew をインストールする。
  # ───────────────────────────────────────────
  system.activationScripts.install-homebrew.text = lib.mkIf (config.homebrew.enable) ''
    if ! command -v brew &>/dev/null; then
      echo "[nix-darwin] Homebrew が見つかりません。自動インストールします..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo "[nix-darwin] Homebrew のインストールが完了しました。"
    else
      echo "[nix-darwin] Homebrew は既にインストールされています (brew --prefix: $(brew --prefix))"
    fi
  '';

  # ───────────────────────────────────────────
  # Homebrew 管理
  # nixpkgs に存在しない macOS 固有パッケージを
  # nix-darwin の homebrew モジュールで宣言的に管理する
  # `darwin-rebuild switch` 実行時に自動で brew install される
  # ───────────────────────────────────────────
  homebrew = {
    enable = true;

    # brew tap が必要なリポジトリ
    taps = [
      "nikitabobko/tap"          # aerospace
    ];

    # CLIツール (brew install)
    brews = [
      # macOS 固有 CLI — nixpkgs未対応
      "blueutil"                 # Bluetooth CLI
      "im-select"                # IME切替 CLI
      "macism"                   # 入力メソッド切替
      "screenresolution"         # 画面解像度設定
    ];

    # GUIアプリ (brew install --cask)
    casks = [
      # ─── ウィンドウ管理 / macOS 統合 ───
      "aerospace"                # タイル型WM (yabaiの代替, nixpkgs未対応)
      "aquaskk"                  # 日本語入力 (SKK)
      "azookey"                  # キー設定
      "boring-notch"             # ノッチ管理
      "jordanbaird-ice"          # メニューバー管理

      # ─── 仮想化 / エミュレーション ───
      "utm"                      # QEMU macOS GUI
      "whisky"                   # Wineラッパー

      # ─── システムユーティリティ ───
      "kegworks"                 # macOS パッケージ管理
      "logi-options+"            # Logitech マウス/キーボード設定
      "macfuse"                  # FUSEカーネル拡張 (nix管理不可)
      "mounty"                   # NTFSマウント

      # ─── 開発ツール ───
      "logisim"                  # 論理回路シミュレータ
      "chromedriver"             # Chromeドライバー

      # ─── コンテナ ───
      # "docker-desktop"         # Docker Desktop — colima (nixpkgs) で代替推奨

      # ─── LaTeX ───
      # "mactex"                 # TeX Live — texlive (nixpkgs) で代替済み

      # ─── ゲーム ───
      "gdlauncher"               # Minecraft Modランチャー

      # ─── その他 ───
      "submariner"               # VPNクライアント
    ];

    # 有効化時の動作
    onActivation = {
      # Homebrew自体の自動更新
      autoUpdate = true;
      # 全brewパッケージの自動アップグレード
      upgrade = true;
      # このファイルに記載のない brew/cask パッケージを自動削除するか
      # 注意: 有効にすると手動で入れたパッケージが消える
      # 移行完了までは "uninstall" 推奨しない
      cleanup = "none"; # "uninstall" | "zap" | "none"
    };

    # Mac App Store アプリ (mas-cli 経由)
    # 必要に応じて追加
    # masApps = {
    #   "Xcode" = 497799835;
    # };
  };

  # ───────────────────────────────────────────
  # プログラム設定
  # ───────────────────────────────────────────
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # ───────────────────────────────────────────
  # Nix 設定
  # ───────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [];
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  # nix-darwin 用 stateVersion
  system.stateVersion = 6;

  # ───────────────────────────────────────────
  # macOS システム設定
  # ───────────────────────────────────────────
  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
      };
    };
    keyboard = {
      enableKeyMapping = true;
    };
  };

  # ───────────────────────────────────────────
  # セキュリティ
  # ───────────────────────────────────────────
  security = {
    pam.services.sudo_local.touchIdAuth = true;
  };
}