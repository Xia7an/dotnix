{ inputs, lib, homeManagerConfig, username, ... }:
let
  fishPackage = homeManagerConfig.programs.fish.package;
  fishShell = lib.getExe fishPackage;
  userRecord = lib.escapeShellArg "/Users/${username}";
in
{
  time.timeZone = "Asia/Tokyo";

  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.fish.package = fishPackage;

  # Home Manager と同じ fish を /etc/shells に登録する。
  environment.shells = [ fishShell ];

  # users.users.<name>.shell では変更されない既存の macOS ユーザーにも適用する。
  # store パスを使うことで、初回の /run/current-system 更新前にも実行できる。
  system.activationScripts.postActivation.text = lib.mkAfter ''
    currentUserShell=$(/usr/bin/dscl . -read ${userRecord} UserShell)
    if [ "$currentUserShell" != ${lib.escapeShellArg "UserShell: ${fishShell}"} ]; then
      echo ${lib.escapeShellArg "setting login shell for ${username} to ${fishShell}..."}
      /usr/bin/dscl . -create ${userRecord} UserShell ${lib.escapeShellArg fishShell}
    fi
  '';

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # llm-agents.nix (AI エージェント一式) のビルド済みバイナリ
      substituters = [
        "https://cache.nixos.org/"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = 6;
}
