{ pkgs, ... }: {
  time.timeZone = "Asia/Tokyo";

  programs.zsh.enable = true;
  programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [];
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = 6;
}
