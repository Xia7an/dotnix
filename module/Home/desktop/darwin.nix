# macOS のデフォルト設定 (Home Manager targets.darwin.defaults)
# Lachesis ホスト固有
{
  targets.darwin.defaults = {
    # キーリピート速度
    "NSGlobalDomain"."KeyRepeat" = 2;
    "NSGlobalDomain"."InitialKeyRepeat" = 15;

    # Finder
    "com.apple.finder"."ShowPathbar" = true;
    "com.apple.finder"."ShowStatusBar" = true;
    "com.apple.finder"."FXPreferredViewStyle" = "Nlsv";

    # Dock
    "com.apple.dock"."autohide" = true;

    # Trackpad (3本指ドラッグ)
    "com.apple.AppleMultitouchTrackpad"."TrackpadThreeFingerDrag" = true;
    "com.apple.driver.AppleMultitouchTrackpad"."TrackpadThreeFingerDrag" = true;
  };
}