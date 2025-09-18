{ pkgs, ... }:

let
  # 1. Wayland対応のVS Codeラッパーを定義する (中間変数にする)
  vscode-wayland-drv = pkgs.symlinkJoin {
    name = "vscode-wayland";
    paths = [ pkgs.vscode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-wayland-ime" \
        --add-flags "--wayland-text-input-version=1"

    '';
  };

  # 2. 上記のラッパーに、元のvscodeからメタ情報を追加する
  vscode-wayland = vscode-wayland-drv // {
    pname = pkgs.vscode.pname;
    version = pkgs.vscode.version;
  };

in
{
  programs.vscode = {
    enable = true;
    # 3. メタ情報を追加した最終的なパッケージを指定する
    package = vscode-wayland;

    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      # ... other extensions
    ];

    userSettings = {
      "editor.fontFamily" = "'HackGen Console NF'";
      "editor.editContext" = false;
    };
  };
}
