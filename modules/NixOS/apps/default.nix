# NixOS レベルのアプリケーション設定
# blender, dolphin, univ は Home Manager 側 (modules/Home/apps/) で管理する
# gaming.nix (Steam) は OS レベルのハードウェア設定が必要なため NixOS 側に残す
{
  imports = [
    ./gaming.nix
  ];
}
