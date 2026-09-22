{
  imports = [
    ./homebrew/formulas.nix
    ./homebrew/applications.nix
    ./homebrew/system.nix
    ./homebrew/development.nix
    ./homebrew/mas.nix
  ];

  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  homebrew = {
    enable = true;

    # 手動の `brew bundle` でも nix-darwin が生成した Brewfile を使用する。
    global.brewfile = true;

    # version :latest や自己更新型の cask も明示的な更新時には対象にする。
    greedyCasks = true;

    extraConfig = ''
      tap "nikitabobko/tap", trusted: { casks: ["aerospace"] }
      tap "teddychan/tap", trusted: { casks: ["ice-2"] }
    '';

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
