{ config, ... }:
{
  imports = [
    ../../../modules/Home/desktop/darwin.nix
    ../../../modules/Home/darwin/fonts.nix
    ../../../modules/Home/darwin/pinentry-mac.nix
    ../../../modules/Home/darwin/m-cli.nix
    ../../../modules/Home/darwin/iterm2.nix
    ../../../modules/Home/darwin/raycast.nix
  ];

  # ログインシェルが Homebrew 版 fish (/opt/homebrew/bin/fish) のため、
  # nix-darwin が生成する /etc/fish/config.fish (sysconfdir=/etc) が読まれない。
  # darwin-rebuild や home-manager 自体を PATH に通すため明示的に追加する。
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
  ];
}
