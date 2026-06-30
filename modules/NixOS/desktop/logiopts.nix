# logiops.nix
{ config, pkgs, lib, ... }:

let
  logidCfg = pkgs.writeText "logid.cfg" ''
    devices: ({
      name: "MX Master 4";

      smartshift: {
        on: true;
        threshold: 30;
        default_threshold: 30;
      };

      hiresscroll: {
        hires: true;
        invert: false;
        target: false;
      };

      # cid はボタンごとの Control ID です。
      # 実機のログに合わせて必要なら差し替えてください。
      buttons: (
        {
          cid: 0xc3;
          action = {
            type: "Keypress";
            keys: ["KEY_LEFTMETA", "KEY_SPACE"];
          };
        },
        { cid: 0xc4; action = { type: "Keypress"; keys: ["KEY_FORWARD"]; }; },
        { cid: 0xc5; action = { type: "Keypress"; keys: ["KEY_ENTER"]; }; }
      );
    });
  '';
in
{
  environment.systemPackages = [ pkgs.logiops ];

  environment.etc."logid.cfg".source = logidCfg;

  systemd.services.logid = {
    description = "LogiOps daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udevd.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.logiops}/bin/logid -c /etc/logid.cfg";
      Restart = "on-failure";
    };
  };
}
