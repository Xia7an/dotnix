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
      cleanup = "none";
    };
  };
}
