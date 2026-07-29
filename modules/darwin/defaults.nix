{ ... }:
{
  system.defaults = {
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
    screencapture.target = "clipboard";
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
        AppleMenuBarVisibleInFullscreen = true;
        AppleMiniaturizeOnDoubleClick = false;
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
            InputSourceKind = "Palette";
          }
        ];
      };
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "10" = {
            enabled = false;
          }; # 日本語入力ソースを選択
          "11" = {
            enabled = false;
          };
          "50" = {
            enabled = false;
          }; # 入力メニューの Spotlight を無効化
          "64" = {
            enabled = false;
          }; # Spotlight 検索を表示 (cmd+space) — Raycast に譲るため無効化
          "79" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                123
                262144
              ];
            };
          }; # 左の Space に移動 (Ctrl+←)
          "81" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                124
                262144
              ];
            };
          }; # 右の Space に移動 (Ctrl+→)
        };
      };
    };
  };
}
