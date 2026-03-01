{ config, pkgs, ... }:

let
  discordWrapped = pkgs.writeShellScriptBin "discord" ''
    exec ${pkgs.discord}/bin/discord --ozone-platform=x11 "$@"
  '';
in
{
  programs.discord = {
    enable = true;
    package = discordWrapped;
  };
    # desktop entry を Discord の公式ものを置き換えて作成
  xdg.desktopEntries.discord = {
    name = "Discord";
    genericName = "Internet Messenger";
    comment = "Discord (forced X11 mode)";
    exec = "${discordWrapped}/bin/discord %U";
    terminal = false;
    type = "Application";
    categories = [ "Network" "InstantMessaging" "Chat" ];
    mimeType = [ "x-scheme-handler/discord" ];
    icon = "discord";
    startupNotify = true;
  };
}

