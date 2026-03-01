{pkgs, config, inputs, ...} : {
  # Rust 開発環境（rustup で cargo と rustc を管理）
  home.packages = with pkgs; [
    rustup
  ];

  # Cargo のバイナリディレクトリを PATH に追加
  home.sessionVariables = {
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };
  
  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
