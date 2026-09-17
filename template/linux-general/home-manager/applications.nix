# Lachesis の Home Manager 構成から Linux で利用できるものを選んでいる。
{
  imports = [
    ../../../modules/Home/apps/ai/codex.nix
    ../../../modules/Home/apps/ai/opencode.nix
    ../../../modules/Home/apps/media/multimedia.nix
    ../../../modules/Home/apps/document/pdf.nix
    ../../../modules/Home/apps/vdesktop/immersed.nix
    ../../../modules/Home/apps/creative/blender.nix
    ../../../modules/Home/apps/creative/musescore.nix
    ../../../modules/Home/apps/browser/chrome.nix
    ../../../modules/Home/apps/document/obsidian.nix
  ];
}
