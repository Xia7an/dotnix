{
  homebrew = {
    enable = true;
    taps = [ "nikitabobko/tap" ];

    brews = [
      "blueutil"
      "im-select"
      "macism"
      "screenresolution"
    ];

    casks = [
      "aerospace"
      "alt-tab"
      "aquaskk"
      "azookey"
      "bitwarden"
      "blender"
      "boring-notch"
      "chromedriver"
      "discord"
      "gdlauncher"
      "ghostty"
      "google-chrome"
      "google-japanese-ime"
      "hammerspoon"
      "iterm2"
      "jordanbaird-ice"
      "kegworks"
      "logi-options+"
      "logisim"
      "macfuse"
      "macvim"
      "mounty"
      "musescore"
      "nextcloud"
      "obsidian"
      "raycast"
      "rstudio"
      "skim"
      "slack"
      "spotify"
      "submariner"
      "tigervnc-viewer"
      "utm"
      "vivaldi"
      "whisky"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
