{ pkgs, ... }: {
  # 開発用アプリケーション
  home.packages = with pkgs; [
    # Unity Hub
    unityhub

    # JetBrains Rider
    jetbrains.rider

    # GitHub Copilot CLI
    # Nixpkgs では github-copilot-cli として提供されている場合があります
    # 利用可能な場合は以下を追加:
    # github-copilot-cli
    # 現時点で Nixpkgs に含まれていない場合は、npm でグローバルインストールするか、
    # overlay を使って追加する必要があります。
    # 例: npm install -g @githubnext/github-copilot-cli
  ];

  # 注意: Unity Hub のライセンス認証や初期設定は手動で行う必要があります
  # Rider のライセンスも同様です
}
