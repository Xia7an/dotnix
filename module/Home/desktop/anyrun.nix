{ lib, pkgs, config, ... }: {
  home.packages = with pkgs; [
    rink
  ];
  programs.anyrun = {
    enable = true;
    extraCss = builtins.readFile ../../../config/anyrun/style.css;
    extraConfigFiles = {
      "applications.ron".text = builtins.readFile ../../../config/anyrun/applications.ron;
      "randr.ron".text = builtins.readFile ../../../config/anyrun/randr.ron;
      "websearch.ron".text = builtins.readFile ../../../config/anyrun/websearch.ron;
      "nix-run.ron".text = builtins.readFile ../../../config/anyrun/nix-run.ron;
    };
    config.plugins = [ 
      "${config.home.homeDirectory}/dotnix/config/anyrun/plugins/libapplications.so"
    ];
  };
  xdg.configFile = lib.mkMerge [
    {
      "anyrun/config.ron".text = lib.mkForce (builtins.readFile ../../../config/anyrun/config.ron);
    }
  ];
}
