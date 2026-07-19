{ inputs, ... }:
{
  time.timeZone = "Asia/Tokyo";

  programs.zsh.enable = true;
  programs.fish.enable = true;

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
