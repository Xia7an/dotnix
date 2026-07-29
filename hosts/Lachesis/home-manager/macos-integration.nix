{ config, ... }:
{
  imports = [
    ../../../modules/Home/desktop/darwin.nix
    ../../../modules/Home/darwin/fonts.nix
    ../../../modules/Home/darwin/pinentry-mac.nix
    ../../../modules/Home/darwin/m-cli.nix
    # iterm2 / raycast は Homebrew cask で管理する (modules/darwin/homebrew/)
  ];

  # darwin-rebuild や home-manager 自体を PATH に通すため明示的に追加する。
  # (ログインシェルは Nix 版 fish /run/current-system/sw/bin/fish に移行済み。
  #  以前は Homebrew 版 fish で /etc/fish/config.fish が読まれなかったため必須だった)
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
  ];
}
