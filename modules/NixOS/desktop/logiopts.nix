{
  lib,
  pkgs,
  ...
}:
let
  configFormat = pkgs.formats.libconfig { };
  configFile = configFormat.generate "logid.cfg" {
    devices = [
      {
        name = "MX Master 4";
        buttons = [
          {
            cid = 195;
            action = {
              type = "Keypress";
              keys = [
                "KEY_LEFTMETA"
                "KEY_TAB"
              ];
            };
          }
          {
            cid = 416;
            action = {
              type = "Keypress";
              keys = [
                "KEY_LEFTMETA"
                "KEY_SPACE"
              ];
            };
          }
        ];
      }
    ];
  };
in
{
  hardware.logitech.wireless.enable = true;

  environment.systemPackages = [ pkgs.logiops ];
  services.dbus.packages = [ pkgs.logiops ];

  systemd = {
    packages = [ pkgs.logiops ];
    services.logid = {
      wantedBy = [ "graphical.target" ];
      serviceConfig.ExecStart = [
        ""
        "${lib.getExe pkgs.logiops} -c ${configFile}"
      ];
    };
  };
}
