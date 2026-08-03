{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # <bits/stdc++.h> は GNU libstdc++ 固有のヘッダなので、macOS の libc++ には無い。
  # g++ (nix の gcc) でコンパイルする分には本家のものが使われるが、clangd は libc++ を
  # 見るため「ファイルが見つからない」となり、以降の補完・診断が全部死ぬ。
  # 標準ヘッダを並べただけの互換ヘッダを用意して clangd の include パスに足しておく。
  clangdInclude = ./clangd-include;

  # clangd のユーザ設定。C ファイルに -std=c++20 が付くとエラーになるので、
  # C++ の拡張子にだけ適用する (clangd の設定で絞れる条件は PathMatch のみ)。
  clangdConfig = ''
    If:
      PathMatch: [.*\.cpp, .*\.cxx, .*\.cc, .*\.hpp, .*\.hh, .*\.ipp]
    CompileFlags:
      Add:
        # compile_commands.json が無い単体ファイルの既定は gnu++17 なので引き上げる
        - -std=c++20
        - -I${clangdInclude}
  '';
in

{
  home.packages = with pkgs; [
    gcc
    gdb
    gnumake
    cmake
    pkg-config
    autogen
    time
    llvm_19
    lldb
  ];

  # 設定ファイルの場所は llvm::sys::path::user_config_directory 依存で、
  # macOS だけ ~/Library/Preferences 配下になる。
  # Linux (libstdc++) には本物の <bits/stdc++.h> があるので何も置かない。
  home.file = lib.optionalAttrs isDarwin {
    "Library/Preferences/clangd/config.yaml".text = clangdConfig;
  };
}
