{
  inputs,
  config,
  pkgs,
  ...
}:
{
  services.xremap = {
    enable = true;
    # flake 既定のパッケージは上流ソースを crane で毎回手元ビルドするため、
    # cache.nixos.org にある nixpkgs 版を使う。modmap しか使わないので版差は問題にならない。
    package = pkgs.xremap;
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
