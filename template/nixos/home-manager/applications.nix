# Lachesis の Home Manager 構成から Linux で利用できるものを選んでいる。
{
  imports = [
    ../../../modules/Home/apps/ai/codex.nix
    ../../../modules/Home/apps/ai/opencode.nix
    ../../../modules/Home/apps/ai/claude.nix
  ];
}
