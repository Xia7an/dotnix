{pkgs, ...} : 
let
  chromeArgs = [ "--ozone-platform-hint=auto" "--enable-wayland-ime" ];
in{
  programs = {
    google-chrome = {
      commandLineArgs = chromeArgs;
      enable = true;
    };
    chromium = {
        commandLineArgs = chromeArgs;
    };
  };
}
