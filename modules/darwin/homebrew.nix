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
      # nix-darwin 25.11 の "uninstall" は Homebrew 6 で廃止された
      # `brew bundle --cleanup` を生成するため、新しいフラグを直接渡す。
      # Brewfile 外の formula/cask は従来どおりアンインストールされる。
      cleanup = "none";
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
