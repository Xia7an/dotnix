{ pkgs, ... }:
let
  vscodeWrapped = pkgs.vscode.overrideAttrs (old: {
    # ./bin/code を置き換える
    postFixup = ''
      wrapProgram $out/bin/code \
        --add-flags "--ozone-platform=x11"
    '';
  });
in
{
  programs.vscode = {
    enable = true;
    # 3. メタ情報を追加した最終的なパッケージを指定する
    package = vscodeWrapped;


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
}
