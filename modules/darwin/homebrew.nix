{
  imports = [
    ./homebrew/formulas.nix
    ./homebrew/applications.nix
    ./homebrew/system.nix
    ./homebrew/development.nix
    ./homebrew/mas.nix
  ];

  homebrew = {
    enable = true;
    taps = [ "nikitabobko/tap" ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Brewfile 外の formula/cask を消すかどうか。整理対象を確認してから
      # "uninstall" に切り替える。確認は `brew bundle cleanup --file=<Brewfile>`
      # (--force 無しなら一覧表示のみ) で行う。
      # nix-darwin 25.11 には "check" がまだ無いので "none" のままにしておく。
      cleanup = "uninstall";
    };
  };
}
