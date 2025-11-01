{ pkgs, ... }:

let
  # 1. Wayland対応のVS Codeラッパーを定義する (中間変数にする)
  vscode-wayland-drv = pkgs.symlinkJoin {
    name = "vscode-wayland";
    paths = [ pkgs.vscode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--enable-wayland-ime" \

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

    # 新しいプロファイル形式に対応
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Vim 拡張
        vscodevim.vim

        # 日本語言語パック
        ms-ceintl.vscode-language-pack-ja

        # Python
        ms-python.python
        ms-python.vscode-pylance

        # Rust
        rust-lang.rust-analyzer

        # Web 開発 (HTML, CSS, JS/TS)
        # (組み込みで提供されているため、追加拡張不要な場合が多い)

        # SSH
        ms-vscode-remote.remote-ssh

        # GitHub Copilot
        github.copilot
        github.copilot-chat

        # Typst
        # nvarner.typst-lsp  # 利用可能な場合
      ];

      userSettings = {
        "editor.fontFamily" = "'HackGen Console NF'";
        "editor.editContext" = false;
        "mcp" = {
        "servers" = {
          "notionMCP" = {
            "command" = "npx";
              "args" = [
                "-y"
                "mcp-remote"
                "https://mcp.notion.com/sse"
              ];
            };
          };
        };
        "chat" = {
          "tools" = {
            "global" = {
              "autoApprove" = true;
            };
          };
        };
      };
    };
  };
}
