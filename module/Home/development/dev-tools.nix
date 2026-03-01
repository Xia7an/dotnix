{ pkgs, ... }: {
  # 開発用 CLI ツール
  home.packages = with pkgs; [
    # ファイルマネージャー
    yazi

    # コンパイラ・ビルドツール (gcc/g++ は gcc パッケージに含まれる)
    gcc

    # mise (開発環境マネージャー、node/cargo などをインストール可能)
    mise

    # uv (Python パッケージマネージャー)
    uv
  ];

  # mise の設定例（オプション）
  # mise で node や cargo を管理する場合は、~/.config/mise/config.toml を作成
  # 例: mise use -g node@20 cargo@latest
  # または home.file でテンプレートを配置可能
}
