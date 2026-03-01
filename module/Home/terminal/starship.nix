{pkgs, ...} : {
  # Starship プロンプトを有効化
  programs.starship = {
    enable = true;
  };
  home.file."starship" = {
    target = ".config/starship.toml";  # 配置先（相対パスOK）
    text = builtins.readFile ./starship.toml;
  };
}
