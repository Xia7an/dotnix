{
  imports = [
    ./profile.nix
    ../../modules/Home/desktop/darwin.nix
    ../../modules/Home/darwin/fonts.nix
    ../../modules/Home/darwin/pinentry-mac.nix
    ../../modules/Home/darwin/m-cli.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.ghostty.settings = {
    font-size = 14;
    theme = "catppuccin-macchiato";
    macos-titlebar-style = "tabs";
    background-opacity = 0.92;
  };
}
