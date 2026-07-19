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
        smartshift = {
          on = true;
          threshold = 30;
          default_threshold = 30;
        };
        hiresscroll = {
          hires = true;
          invert = false;
          target = false;
        };
        buttons = [
          {
            cid = 195;
            action = {
              type = "Keypress";
              keys = [
                "KEY_LEFTMETA"
                "KEY_SPACE"
              ];
            };
          }
          {
            cid = 196;
            action = {
              type = "Keypress";
              keys = [ "KEY_FORWARD" ];
            };
          }
          {
            cid = 197;
            action = {
              type = "Keypress";
              keys = [ "KEY_ENTER" ];
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
      description = "LogiOps daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udevd.service" ];
      serviceConfig = {
        ExecStart = [
          ""
          "${lib.getExe pkgs.logiops} -c ${configFile}"
        ];
        Restart = "on-failure";
      };
    };
  };
}
