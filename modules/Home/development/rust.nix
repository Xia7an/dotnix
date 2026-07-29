{ pkgs, config, ... }:
{
  # Rust 開発環境（rust-overlay の rust-bin で cargo と rustc を管理）
  home.packages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "clippy"
      ];
    })
  ];

  # Cargo のバイナリディレクトリを PATH に追加
  home.sessionVariables = {
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
