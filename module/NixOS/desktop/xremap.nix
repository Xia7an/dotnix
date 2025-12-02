{inputs, config, pkgs, ...} : {
  services.xremap = {
    enable = true;
    userName = "inoyu";
    serviceMode = "system";
    config = {
      modmap = [
        {
          # CapsLockを左Ctrlに置換
          name = "CapsLock to Left Ctrl";
          remap = {
            "KEY_CAPSLOCK" = "KEY_LEFTCTRL";
          };
        }
        {
          # AltとWinを入れ替え
          name = "swap alt and win";
          remap = {
            "KEY_LEFTALT" = "KEY_LEFTMETA";
            "KEY_LEFTMETA" = "KEY_LEFTALT";
          };
        }
      ];
    };
  };
}