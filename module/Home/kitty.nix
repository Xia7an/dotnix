{
  programs.kitty = {
    enable = true;
#    themeFile = "../../config/kitty/NightLion_v1.conf";
  };
  home.file.".config/kitty/theme.conf" = {
  source = ../../config/kitty/NightLion_v1.conf;
  };
}
