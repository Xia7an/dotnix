# このリポジトリで定義する自作パッケージ (modules/pkgs/) を pkgs に追加する overlay。
# system 非依存なので、flake の overlays.default としてそのまま外部に公開できる。
_final: prev: {
  niri-taskbar = prev.callPackage ../pkgs/niri-taskbar { };
}
