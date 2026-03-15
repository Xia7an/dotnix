{ pkgs, ... }:
let
  vscodeWrapped = pkgs.vscode.overrideAttrs (old: {
    # ./bin/code を置き換える
    postFixup = ''
      wrapProgram $out/bin/code \
        # --add-flags "--ozone-platform=x11"
    '';
  });
in
{
  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-extensions; [
      # Vim 拡張
      vscodevim.vim


      # 日本語言語パック
      ms-ceintl.vscode-language-pack-ja

      # C/C++
      ms-vscode.cpptools

      # Python
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter

      # Rust
      rust-lang.rust-analyzer

      # Nix
      jnoortheen.nix-ide

      # Web 開発 (HTML, CSS, JS/TS)
      ecmel.vscode-html-css
      biomejs.biome

      # SSH
      ms-vscode-remote.remote-ssh

      # GitHub Copilot
      github.copilot
      github.copilot-chat

      # Typst
      myriad-dreamin.tinymist
      tomoki1207.pdf
      # nvarner.typst-lsp  # 利用可能な場合


      # 便利拡張
      usernamehw.errorlens
      ms-vscode.hexeditor
      davidanson.vscode-markdownlint
    ];

    userSettings = {
      "locale" = "ja";
      "editor.fontFamily" = "'HackGen Console NF'";
      "editor.acceptSuggestionOnCommitCharacter" = false;
      "editor.inlineSuggest.enabled" = false;
      "keyboard.dispatch" = "keyCode";
      "chat.tools.global.autoApprove" = true;

      # 今後勝手に書き換わらないようにするための追加設定
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "update.mode" = "none";
    };

    keybindings = [
      # エディター(Vimノーマルモード)からエクスプローラーへ
      {
        key = "ctrl+shift+h";
        command = "workbench.view.explorer";
        when = "editorFocus && vim.mode == 'Normal'";
      }
      # ターミナルからエクスプローラーへ
      {
        key = "ctrl+shift+h";
        command = "workbench.view.explorer";
        when = "terminalFocus";
      }
      # エクスプローラーからエディターへ
      {
        key = "ctrl+shift+l";
        command = "workbench.action.focusActiveEditorGroup";
        when = "explorerViewletFocus && explorerViewletVisible && !inputFocus";
      }
      # エクスプローラーからターミナルへ
      {
        key = "ctrl+shift+j";
        command = "workbench.action.terminal.focus";
        when = "explorerViewletFocus && explorerViewletVisible && !inputFocus";
      }
      # エディター(Vimノーマルモード)からターミナルへ
      {
        key = "ctrl+shift+j";
        command = "workbench.action.terminal.focus";
        when = "editorFocus && explorerViewletVisible && vim.mode == 'Normal'";
      }
      # ターミナルからエディターへ
      {
        key = "ctrl+shift+k";
        command = "workbench.action.focusActiveEditorGroup";
        when = "terminalFocus";
      }
      # デフォルトキーバインドの無効化
      {
        key = "ctrl+shift+k";
        command = "-editor.action.deleteLines";
        when = "textInputFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+h";
        command = "-workbench.action.replaceInFiles";
      }
      {
        key =  "ctrl+w";
        command =  "-extension.vim_ctrl+w";
        when = "editorTextFocus && vim.active && vim.use<C-w> && !inDebugRepl";
      }
    ];
  };
  xdg.configFile."code-flags.conf" = {
    text = ''
--enable-wayland-ime
--enable-features=UseOzonePlatform,WaylandWindowDecorations
--ozone-platform=wayland
--gtk-version=4
--disable-features=WaylandTextInputV3
--ime-mode=async
'';
  };

  xdg.configFile."Code/User/mcp.json".text = builtins.toJSON {
    servers = {
      notionMCP = {
        command = "npx";
        args = [
          "-y"
          "mcp-remote"
          "https://mcp.notion.com/sse"
        ];
        type = "stdio";
      };
    };
    inputs = [ ];
  };
  
  # VSCode argv.json でIME設定を追加
  # home.file.".vscode/argv.json".text = builtins.toJSON {
  #   enable-crash-reporter = true;
  #   crash-reporter-id = "1a93b80d-ce8f-4f89-ab61-829c60f7e187";
  #   password-store = "basic";
  #   locale = "ja";
  #   disable-hardware-acceleration = false;
  #   enable-wayland-ime = true;
  # };
}
