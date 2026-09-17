{ config, lib, pkgs, ... }:
let
  loginShell = "${config.home.profileDirectory}/bin/fish";
  # OS のアカウント情報と setuid sudo を使うため、ホスト側のコマンドを指定する。
  setLoginShell = ''
    shell=${lib.escapeShellArg loginShell}
    user=${lib.escapeShellArg config.home.username}
    if [ ! -x "$shell" ]; then
      echo "Login shell is not executable: $shell" >&2
      exit 1
    fi
    entry=$(/usr/bin/getent passwd "$user")
    if ! /usr/bin/grep -qxF -- "$shell" /etc/shells; then
      printf '\n%s\n' "$shell" >> /etc/shells
    fi
    if [ "''${entry##*:}" != "$shell" ]; then
      /usr/bin/chsh -s "$shell" "$user"
    fi
  '';
in
{
  targets.genericLinux = {
    enable = true;
    gpu.enable = pkgs.stdenv.hostPlatform.isx86_64;
  };

  imports = [
    ./home-manager/applications.nix
    ./home-manager/development-tools.nix
    ./home-manager/editors.nix
    ./home-manager/shell-and-command-line.nix
    ./home-manager/terminal-emulators.nix
  ];

  assertions = [{
    assertion = config.programs.fish.enable;
    message = "hermes requires programs.fish.enable for its managed login shell.";
  }];

  # パッケージをプロファイルに配置してから変更する。run は dry-run 時には実行しない。
  home.activation.fishLoginShell = lib.hm.dag.entryAfter [ "installPackages" ] ''
    entry=$(/usr/bin/getent passwd ${lib.escapeShellArg config.home.username})
    if [ "''${entry##*:}" != ${lib.escapeShellArg loginShell} ] \
      || ! /usr/bin/grep -qxF -- ${lib.escapeShellArg loginShell} /etc/shells; then
      run /usr/bin/sudo /bin/sh -eu -c ${lib.escapeShellArg setLoginShell}
    fi
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.ghostty.settings = {
    font-size = 14;
    theme = "Catppuccin Macchiato";
    background-opacity = 0.92;
  };
}
