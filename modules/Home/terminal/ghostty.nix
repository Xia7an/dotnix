{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    enableFishIntegration = true;
    settings = {
      theme = "Dracula";
      font-family = "HackGen Console NF";
      font-size = 13;
      window-decoration = false;
      cursor-style = "bar";
      cursor-style-blink = true;
      scrollback-limit = 10000;
    };
  };
}
