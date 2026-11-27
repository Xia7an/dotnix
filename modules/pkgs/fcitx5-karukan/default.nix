# karukan (ニューラルかな漢字変換の日本語 IME) の fcitx5 アドオン。
# https://github.com/togatoga/karukan
#
# 上流はバイナリを配布しておらず nixpkgs にも無いので、ここでソースからビルドする。
# (AGENTS.md の「手元ビルドが必要なパッケージは使わない」の例外)
#
# ビルドの流れは上流の手順どおり CMake (karukan-im/fcitx5/fcitx5-addon) が
# 内部で `cargo build --release -p karukan-fcitx5` を呼ぶ形。
# crate の依存は cargoSetupHook でオフライン化した vendor ディレクトリから解決する。
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  rustPlatform,
  cargo,
  rustc,
  cmake,
  extra-cmake-modules,
  pkg-config,
  patchelf,
  fcitx5,
  libxkbcommon,
}:

let
  rev = "2f0a00a1802538b668e11b49760d4a97f717b637";
  shortRev = builtins.substring 0 7 rev;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-karukan";
  version = "0.1.0-unstable-2026-11-21";

  src = fetchFromGitHub {
    owner = "togatoga";
    repo = "karukan";
    inherit rev;
    hash = "sha256-Qkubj92MZM7EfoWJKg0mCCrPDxNWkjz/YYsEa7Fs6JY=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/Cargo.lock";
  };

  # CMakeLists.txt は karukan-im/fcitx5/fcitx5-addon にある。
  # cmake hook は <src>/build で configure するので、そこからの相対パス。
  cmakeDir = "../karukan-im/fcitx5/fcitx5-addon";

  cmakeFlags = [
    # 既定の -C target-cpu=native (と llama.cpp の GGML_NATIVE) は
    # ビルドマシン依存になり再現性が壊れるので切る。
    (lib.cmakeBool "KARUKAN_NATIVE" false)
  ];

  # 「ばーじょん」変換やログに出るバージョン。tarball には .git が無いので明示する。
  env.KARUKAN_VERSION = "${finalAttrs.version}+g${shortRev}";

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    patchelf
    cargo
    rustc
    rustPlatform.cargoSetupHook
    # llama-cpp-sys-2 の bindgen が libclang を使う
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fcitx5
    libxkbcommon
  ];

  # karukan.so は CMake にフルパスで渡された libkarukan_fcitx5.so にリンクされる。
  # cdylib に SONAME が付かない場合は DT_NEEDED にビルドディレクトリの絶対パスが
  # 埋め込まれてしまうので、ファイル名だけに直して同じディレクトリから引かせる。
  postFixup = ''
    addon="$out/lib/fcitx5/karukan.so"
    for needed in $(patchelf --print-needed "$addon"); do
      case "$needed" in
        */libkarukan_fcitx5.so)
          patchelf --replace-needed "$needed" libkarukan_fcitx5.so "$addon"
          ;;
      esac
    done
    patchelf --add-rpath "$out/lib/fcitx5" "$addon"
  '';

  passthru = {
    # 上流リリースのビルド済みシステム辞書 (SudachiDict 由来)。
    # アーカイブを展開するだけの fixed-output derivation なのでビルドは走らない。
    dictionary = fetchzip {
      url = "https://github.com/togatoga/karukan/releases/download/v0.1.0/dict.tgz";
      stripRoot = false;
      hash = "sha256-gWUZH3FQfuksslb/AqUvBU0OVFe9DMg0+8SpGHlASqA=";
    };
  };

  meta = {
    description = "Japanese input method for fcitx5 with neural kana-kanji conversion";
    homepage = "https://github.com/togatoga/karukan";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
