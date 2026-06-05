{ ... }:

{
  hardware.logitech.wireless.enable = true;

  services.logiops = {
    enable = true;

    config = {
      devices = [
        {
          name = "MX Master 4";

          buttons = [
            {
              cid = 0xc3;
              action = {
                type = "Keypress";
                keys = [ "KEY_LEFTMETA" "KEY_TAB" ];
              };
            }

            {
              cid = 0x1a0;
              action = {
                type = "Keypress";
                keys = [ "KEY_LEFTMETA" "KEY_SPACE" ];
              };
            }
          ];
        }
      ];
    };
  };
}
