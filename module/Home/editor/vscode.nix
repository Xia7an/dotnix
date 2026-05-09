{ pkgs, ... }:
let
  marketplaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    { name = "vscode-sqlite"; publisher = "alexcvzz"; version = "0.14.1"; sha256 = "1iaklnhw74iwyjw74prnrx34ba25ra7ld71zlip04lv401329r4c"; }
    { name = "html-preview-vscode"; publisher = "george-alisson"; version = "0.2.5"; sha256 = "1n41xb22cqpn0058qksyx1xp00zjx5gf8a497lhsnlain4sf2j6n"; }
    { name = "markdown-alert"; publisher = "kejun"; version = "0.0.4"; sha256 = "1jfydk7fsfm760lfgs6igv2xfy62gna49pjq95dmx3cwvabyc8wd"; }
    { name = "language-matlab"; publisher = "mathworks"; version = "1.3.10"; sha256 = "1xn3zg65pwbm7iablxbwx3vpngipkqm7bjap2bvb9wpgbwksb002"; }
    { name = "cpp-devtools"; publisher = "ms-vscode"; version = "0.5.13"; sha256 = "0g2nmpvhfx2yrsb9k1qfrc66hghv1iabqms54hjal1qa91s5gil3"; }
    { name = "cpptools-themes"; publisher = "ms-vscode"; version = "2.0.0"; sha256 = "05r7hfphhlns2i7zdplzrad2224vdkgzb0dbxg40nwiyq193jq31"; }
    { name = "vscode-websearchforcopilot"; publisher = "ms-vscode"; version = "0.1.4"; sha256 = "1m791c502mnzgnz85ipc6v9wd1ay7c3hzdwgahzk2i6adz6inih3"; }
    { name = "sqltools"; publisher = "mtxr"; version = "0.28.5"; sha256 = "13za2a9s1jrl26rakfww4hf3pkvkvkkkqx76kji7flwdqr20366q"; }
    { name = "sqltools-driver-mysql"; publisher = "mtxr"; version = "0.6.6"; sha256 = "1ykkppirpq1rh2ac2j3zscgdz2fbs3add9ri1qp7pfcpi4r9lw9f"; }
    { name = "vscode-paste-image"; publisher = "mushan"; version = "1.0.4"; sha256 = "1wkplvrn31vly5gw35hlgpjpxgq3dzb16hz64xcf77bwcqfnpakb"; }
    { name = "background"; publisher = "shalldie"; version = "2.0.10"; sha256 = "15p3rqsvraiaq3x5xls565l9ysmiahqh9zf9y6cgzj5brl99qhys"; }
    { name = "open-in-browser"; publisher = "techer"; version = "2.0.0"; sha256 = "1s5mgw0jaasis0ish3da3dl7vqsgkx9cgrp1mmpgh9c4wlr12xnx"; }
  ];

  darwinMarketplaceExtensions = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin (
    pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      { name = "vscode-python-envs"; publisher = "ms-python"; version = "1.30.0"; sha256 = "1rh7pfc4v4rbqi115zszrx35dcm4vl4prhy9h0vb090yrxzh73rm"; arch = "darwin-arm64"; }
      { name = "typst-lsp"; publisher = "nvarner"; version = "0.13.0"; sha256 = "07zdbar4i46qa23l0q1b3n117bjcr14l2r4k51qnjns9qf0z137f"; arch = "darwin-arm64"; }
      { name = "chatgpt"; publisher = "openai"; version = "26.506.21252"; sha256 = "1ihdz2rrqarpnsqfp7xvdqg8c9cnfq7ldcvxph30dzrxxiwrqxcf"; arch = "darwin-arm64"; }
    ]
  );

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

    profiles.default = {
      extensions =
      (with pkgs.vscode-extensions; [
        # General
        vscodevim.vim
        ms-ceintl.vscode-language-pack-ja
        usernamehw.errorlens
        ms-vscode.hexeditor
        wakatime.vscode-wakatime
        saoudrizwan.claude-dev

        # Nix / Web / Markdown
        bbenoist.nix
        biomejs.biome
        ecmel.vscode-html-css
        bierner.markdown-preview-github-styles
        shd101wyy.markdown-preview-enhanced

        # Python / Notebook
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow

        # Native / Containers / Remote
        ms-azuretools.vscode-containers
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.remote-explorer
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        vadimcn.vscode-lldb
        twxs.cmake

        # Languages
        dart-code.dart-code
        dart-code.flutter
        github.vscode-github-actions
        hediet.vscode-drawio
        james-yu.latex-workshop
        mechatroner.rainbow-csv
        mhutchie.git-graph
        myriad-dreamin.tinymist
        redhat.java
        reditorsupport.r
        reditorsupport.r-syntax
        ritwickdey.liveserver
        rust-lang.rust-analyzer
        sonarsource.sonarlint-vscode
        tomoki1207.pdf
        vscjava.vscode-gradle
        vscjava.vscode-java-debug
        vscjava.vscode-java-dependency
        vscjava.vscode-java-pack
        vscjava.vscode-java-test
        vscjava.vscode-maven
      ])
      ++ marketplaceExtensions
      ++ darwinMarketplaceExtensions;

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
