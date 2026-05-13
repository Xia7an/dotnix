{ config, lib, ... }: {
  system.activationScripts.install-homebrew.text = lib.mkIf (config.homebrew.enable) ''
    if ! command -v brew &>/dev/null; then
      echo "[nix-darwin] Homebrew が見つかりません。自動インストールします..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo "[nix-darwin] Homebrew のインストールが完了しました。"
    else
      echo "[nix-darwin] Homebrew は既にインストールされています (brew --prefix: $(brew --prefix))"
    fi
  '';

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
      "aquaskk"
      "azookey"
      "google-japanese-ime"
      "boring-notch"
      "jordanbaird-ice"
      "utm"
      "whisky"
      "kegworks"
      "logi-options+"
      "macfuse"
      "mounty"
      "logisim"
      "chromedriver"
      "gdlauncher"
      "submariner"
    ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none";
    };
  };
}
