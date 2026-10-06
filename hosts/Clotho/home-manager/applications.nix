# Clotho 用アプリケーション設定
{
  imports = [
    # WSL は CLI を使い、GUI は Windows 側の ChatGPT アプリで管理する。
    ../../../modules/Home/apps/ai/codex.nix
    ../../../modules/Home/apps/ai/claude.nix
  ];
}
