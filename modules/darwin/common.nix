{ inputs, pkgs, ... }:
{
  time.timeZone = "Asia/Tokyo";

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # ログインシェルに指定できるよう /etc/shells に登録する。
  # 実際の切り替えは `chsh -s /run/current-system/sw/bin/fish` で行う
  # (macOS の既存ユーザーは nix-darwin の users.users.<name>.shell の対象外)。
  environment.shells = [ pkgs.fish ];

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = 6;
}
