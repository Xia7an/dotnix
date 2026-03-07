# NixOS レベルのアプリケーション設定
# Discord は Wayland ラッパーが必要なため Home Manager 側 (module/Home/apps/discord.nix) で管理する
{
  imports = [
    ./blender.nix
    ./dolphin.nix
    ./gaming.nix
    ./univ
  ];
}
