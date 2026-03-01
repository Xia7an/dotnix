{pkgs, ...}: {
  # Biome - JavaScript/TypeScript/JSON/CSS のための高速フォーマッター・リンター
  home.packages = with pkgs; [
    biome
  ];

  # オプション: Biome のグローバル設定ファイル
  # プロジェクトごとに biome.json を配置する場合は不要
  # home.file.".config/biome/biome.json".text = builtins.toJSON {
  #   "$schema" = "https://biomejs.dev/schemas/1.9.4/schema.json";
  #   organizeImports = { enabled = true; };
  #   linter = {
  #     enabled = true;
  #     rules = { recommended = true; };
  #   };
  #   formatter = {
  #     enabled = true;
  #     indentStyle = "space";
  #     indentWidth = 2;
  #   };
  # };
}