{pkgs, inputs, ...} : {
    programs.rust = {
    enable = true;          # Rust を有効化
    package = pkgs.rustup;  # rustup 経由でインストール
  };

  # PATH に ~/.cargo/bin を追加
  home.sessionVariables = {
    PATH = "${pkgs.rustup}/bin:${pkgs.cargo}/bin:${pkgs.zsh}/bin:${config.home.path}";
  };
}
