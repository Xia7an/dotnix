# NixOS レベルのアプリケーション設定
# Discord は Wayland ラッパーが必要なため Home Manager 側 (module/Home/apps/discord.nix) で管理する
# gaming.nix (Steam) は Atropos 固有のため hosts/Atropos/default.nix でインポートする
{
  imports = [
    ./blender.nix
    ./dolphin.nix
    ./univ
  ];
}
