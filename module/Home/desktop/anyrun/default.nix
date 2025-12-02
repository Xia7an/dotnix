{ lib, pkgs, ... }:
{
  programs.anyrun = {
    enable = true;
    config = {
      # Position & Size
      x = { fraction = 0.5; };
      y = { absolute = 128; };
      width = { absolute = 800; };
      height = { absolute = 0; };

      # Appearance & Behavior
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = true;
      maxEntries = null;

      # Plugins
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
    };
    extraConfigFiles = {
      "applications.ron".text = builtins.readFile ./applications.ron;

      "shell.ron".text = ''
        Config(
          prefix: ":sh",
          shell: None,
        )
      '';

      "websearch.ron".text = ''
        Config(
          prefix: "?",
          engines: [Google] 
        )
      '';

      "translate.ron".text = ''
        Config(
          prefix: ":tr",
          language_delimiter: ">",
          max_entries: 3,
        )
      '';
      "style.css".text = builtins.readFile ./style.css;
    };
  };
  
}