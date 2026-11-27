# このリポジトリで定義する自作パッケージ (modules/pkgs/) を pkgs に追加する overlay。
# system 非依存なので、flake の overlays.default としてそのまま外部に公開できる。
final: prev: {
  niri-taskbar = prev.callPackage ../pkgs/niri-taskbar { };

  # karukan は rust-version = 1.92 を要求する。stable (nixos-25.11) の rustc が
  # 足りない間は、キャッシュ済みの unstable のツールチェインでビルドする。
  fcitx5-karukan = prev.callPackage ../pkgs/fcitx5-karukan (
    prev.lib.optionalAttrs (!prev.lib.versionAtLeast prev.rustc.version "1.92") {
      inherit (final.unstable) cargo rustc;
      rustPlatform = prev.makeRustPlatform { inherit (final.unstable) cargo rustc; };
    }
  );
}
