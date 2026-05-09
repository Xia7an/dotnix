# Lachesis ホスト固有の nix-darwin 設定
# macOS Sequoia 26.2 — Apple Silicon (aarch64-darwin) 用
# 最終目標: `darwin-rebuild switch` 一発でこのMacの環境を完全再現する
{ config, pkgs, inputs, lib, ... }: {
  imports = [ ];

  # ───────────────────────────────────────────
  # ホスト基本情報
  # ───────────────────────────────────────────
  networking.hostName = "Lachesis";
  networking.localHostName = "INOYU-MacBookPro";
  networking.computerName = "混沌を超えし我らが神聖なる調律主のMacBook Pro";
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
      "google-japanese-ime"      # 実ホストで選択中の IME
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
        expose-group-apps = false;
        largesize = 102;
        magnification = true;
        minimize-to-application = false;
        mineffect = "genie";
        mru-spaces = false;
        orientation = "bottom";
        show-recents = false;
        showAppExposeGestureEnabled = false;
        showMissionControlGestureEnabled = true;
      };
      finder = {
        AppleShowAllExtensions = false;
        FXPreferredViewStyle = "icnv";
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
      };
      magicmouse.MouseButtonMode = "OneButton";
      NSGlobalDomain = {
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleMenuBarVisibleInFullscreen = true;
        AppleMiniaturizeOnDoubleClick = false;
        ApplePressAndHoldEnabled = false;
        AppleSpacesSwitchOnActivate = false;
        AppleWindowTabbingMode = "always";
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      menuExtraClock = {
        FlashDateSeparators = true;
        IsAnalog = false;
        ShowAMPM = true;
        ShowDate = 0;
        ShowDayOfWeek = true;
        ShowSeconds = true;
      };
      screencapture = {
        target = "clipboard";
      };
      trackpad = {
        ActuateDetents = true;
        Clicking = false;
        DragLock = false;
        Dragging = false;
        FirstClickThreshold = 1;
        ForceSuppressed = false;
        SecondClickThreshold = 1;
        TrackpadCornerSecondaryClick = 0;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadMomentumScroll = true;
        TrackpadPinch = true;
        TrackpadRightClick = true;
        TrackpadRotate = true;
        TrackpadThreeFingerDrag = false;
        TrackpadThreeFingerHorizSwipeGesture = 2;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 2;
        TrackpadTwoFingerDoubleTapGesture = true;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
          NSQuitAlwaysKeepsWindows = true;
          "_HIHideMenuBar" = false;
        };

        "com.apple.HIToolbox" = {
          AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.ABC";
          AppleDictationAutoEnable = true;
          AppleEnabledInputSources = [
            {
              "Bundle ID" = "com.apple.inputmethod.Kotoeri.RomajiTyping";
              "Input Mode" = "com.apple.inputmethod.Japanese";
              InputSourceKind = "Input Mode";
            }
            {
              "Bundle ID" = "com.apple.inputmethod.Kotoeri.RomajiTyping";
              InputSourceKind = "Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.apple.CharacterPaletteIM";
              InputSourceKind = "Non Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.apple.50onPaletteIM";
              InputSourceKind = "Non Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.apple.PressAndHold";
              InputSourceKind = "Non Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.apple.inputmethod.ironwood";
              InputSourceKind = "Non Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.apple.inputmethod.Kotoeri.RomajiTyping";
              "Input Mode" = "com.apple.inputmethod.Roman";
              InputSourceKind = "Input Mode";
            }
          ];
          AppleFnUsageType = 1;
          AppleSelectedInputSources = [
            {
              "Bundle ID" = "com.apple.PressAndHold";
              InputSourceKind = "Non Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.google.inputmethod.Japanese";
              "Input Mode" = "com.apple.inputmethod.Roman";
              InputSourceKind = "Input Mode";
            }
          ];
        };

        "com.apple.WindowManager" = {
          AppWindowGroupingBehavior = 1;
          AutoHide = false;
          EnableStandardClickToShowDesktop = true;
          EnableTiledWindowMargins = false;
          GloballyEnabled = false;
          HideDesktop = true;
          StageManagerHideWidgets = false;
          StandardHideWidgets = false;
        };

        "com.apple.controlcenter" = {
          AutoHideMenuBarOption = 3;
        };

        "com.apple.screencapture" = {
          style = "selection";
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
    };
  };

  system.activationScripts.postUserPreferences.text = ''
    # 電源まわりは defaults では表現できないため root で揃える
    /usr/bin/pmset -a \
      displaysleep 10 \
      disksleep 10 \
      sleep 1 \
      lowpowermode 0 \
      standby 1 \
      ttyskeepawake 1 \
      hibernatemode 3 \
      powernap 1 \
      tcpkeepalive 1 \
      womp 1 \
      networkoversleep 0
  '';

  # ───────────────────────────────────────────
  # セキュリティ
  # ───────────────────────────────────────────
  security = {
    pam.services.sudo_local.touchIdAuth = true;
  };
}
