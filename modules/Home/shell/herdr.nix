# herdr (https://herdr.dev) はマウスファーストなターミナルマルチプレクサ。
# nixpkgs に未収録のため、公式インストールスクリプト (https://herdr.dev/install.sh)
# が配布している GitHub Releases のプリビルドバイナリを直接取得してパッケージ化する。
{ pkgs, lib, ... }:
let
  version = "0.7.5";

  platforms = {
    aarch64-darwin = {
      asset = "herdr-macos-aarch64";
      sha256 = "1mmhyn7mw0dq4x1b9bjv75jf5r2xcrigkslj7fa5a981n130ad9p";
    };
    x86_64-darwin = {
      asset = "herdr-macos-x86_64";
      sha256 = "0qlysq4385cly22dfmmfsdf6bcyx5231f8hkdcq050fwcd50rr9z";
    };
    aarch64-linux = {
      asset = "herdr-linux-aarch64";
      sha256 = "1fd817zbcv9d456zmz1lkzdf2fvl5c34z3kh3m5njsws96hn7rrj";
    };
    x86_64-linux = {
      asset = "herdr-linux-x86_64";
      sha256 = "0lwjqnajw50rjaxxn5zxqr0r3jmwjyzffc4scwy2sk1y0y435j1x";
    };
  };

  system = pkgs.stdenv.hostPlatform.system;
  platform =
    platforms.${system} or (throw "herdr.nix: unsupported system ${system}");

  herdr = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/${platform.asset}";
      sha256 = platform.sha256;
    };

    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [
      pkgs.autoPatchelfHook
    ];
    buildInputs = lib.optionals pkgs.stdenv.isLinux [
      pkgs.stdenv.cc.cc.lib
      pkgs.openssl
      pkgs.zlib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/herdr
      runHook postInstall
    '';

    meta = {
      description = "Mouse-first terminal multiplexer built for coding agents";
      homepage = "https://herdr.dev";
      license = lib.licenses.asl20;
      platforms = builtins.attrNames platforms;
      mainProgram = "herdr";
    };
  };
  # ghq のリポジトリを fzf で選び、新しい workspace として開くスクリプト。
  # TOML のクォート処理は formats.toml に任せる (Nix の '' エスケープと
  # TOML のリテラル複数行文字列 ''' が衝突するため、手書きすると壊れる)。
  ghqSpaceScript = ''
    repo="$(ghq list -p | fzf --prompt='space> ')" || exit 0
    [ -n "$repo" ] || exit 0

    herdr_bin="''${HERDR_BIN_PATH:-herdr}"
    label="$(basename "$repo")"

    "$herdr_bin" workspace create --cwd "$repo" --label "$label" --focus
  '';

  tomlFormat = pkgs.formats.toml { };

  configFile = tomlFormat.generate "herdr-config.toml" {
    keys = {
      # navigate モード (prefix+w のワークスペースピッカー) を vim 風に。
      # 既定では workspace 選択が up/down、pane 移動が h/j/k/l なので、
      # j/k を workspace 選択に譲り、pane の上下移動を矢印キーへ退避する。
      navigate_workspace_down = "j";
      navigate_workspace_up = "k";
      navigate_pane_down = "down";
      navigate_pane_up = "up";

      command = [{
        key = "prefix+o";
        type = "pane";
        command = ghqSpaceScript;
        description = "open ghq space";
      }];
    };
  };
in {
  home.packages = [ herdr ];

  xdg.configFile."herdr/config.toml".source = configFile;
}
