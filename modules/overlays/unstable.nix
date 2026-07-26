# nixpkgs-unstable のパッケージ一式を pkgs.unstable として公開する overlay。
#
# stable 側の名前は一切上書きしない。unstable 版が欲しい箇所では
# 呼び出し側が pkgs.unstable.<pkg> と明示的に書く。
# こうすることで、モジュールを読むだけでどのチャンネル由来かが分かる。
#
# nixpkgs-unstable の import は overlay の外 (default.nix) で system ごとに 1 回だけ行い、
# ここには出来上がった package set を渡すだけにしている。
# overlay の内部で import nixpkgs するとクロスコンパイルが壊れ、
# nixpkgs の fixpoint が余分に増えて評価コストも二重になるため。
unstablePkgs: _final: _prev: {
  unstable = unstablePkgs;
}
