{ pkgs, lib, ... }:
let
  # tinymist のバックグラウンドプレビューが待ち受けるアドレス
  typstPreviewHost = "127.0.0.1:23635";
  openCommand = if pkgs.stdenv.hostPlatform.isDarwin then "open" else "xdg-open";
in
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.unstable.zed-editor;

    # Zed 専用の PATH に LSP/フォーマッタ/デバッガを同梱する。
    # PATH の末尾に足されるので、direnv 等でプロジェクト側に入っているものがあればそちらが優先される。
    # (Zed が自動ダウンロードするバイナリは NixOS では動かないので、Nix から渡しておく)
    extraPackages = with pkgs.unstable; [
      # C/C++
      clang-tools # clangd, clang-format
      # Python (.venv があれば Zed がツールチェーンとして自動選択し、basedpyright に渡す)
      basedpyright
      ruff
      # Haskell (HLS は GHC が無いと解析できないので単体ファイル用に同梱)
      haskell-language-server
      ghc
      cabal-install
      # Go
      gopls
      gotools
      delve
      # Rust (cargo/rustc は modules/Home/development/rust.nix の rust-bin)
      rust-analyzer
      # Typst
      tinymist
      typstyle
      # Nix
      nil
      nixfmt
    ];

    # This populates the userSettings "auto_install_extensions"
    # C/C++, JS/TS, Python, Go, Rust は Zed 組み込み。Haskell と Typst は拡張が必要。
    extensions = [
      "nix"
      "toml"
      "elixir"
      "make"
      "html"
      "python"
      "haskell"
      "typst"
    ];

    userTasks = [
      {
        # tinymist のバックグラウンドプレビュー (フォーカス中の .typ を追従) をブラウザで開く
        label = "Typst: ライブプレビューを開く";
        command = openCommand;
        args = [ "http://${typstPreviewHost}" ];
        reveal = "never";
        hide = "always";
      }
      {
        # 現在のファイルを固定してプレビューしたいとき用 (ブラウザが自動で開く)
        label = "Typst: このファイルをプレビュー";
        command = "tinymist";
        args = [
          "preview"
          "--invert-colors=never"
          "$ZED_FILE"
        ];
        use_new_terminal = true;
        allow_concurrent_runs = true;
        reveal = "no_focus";
      }
    ];

    # Everything inside of these brackets are Zed options
    userSettings = {
      agent = {
        enabled = true;
        version = "2";
        default_open_ai_model = null;
        default_profile = "write";

        # Provider options:
        # - zed.dev models (claude-3-5-sonnet-latest) requires GitHub connected
        # - anthropic models (claude-3-5-sonnet-latest, claude-3-haiku-latest, claude-3-opus-latest) requires API_KEY
        # - copilot_chat models (gpt-4o, gpt-4, gpt-3.5-turbo, o1-preview, gpt-5-mini) requires GitHub connected
        model_parameters = [ ];
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      hour_format = "hour24";
      auto_update = false;

      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = false;
        dock = "bottom";
        detect_venv = {
          on = {
            directories = [
              ".env"
              "env"
              ".venv"
              "venv"
            ];
            activate_script = "default";
          };
        };
        env = {
          TERM = "ghostty";
        };
        font_family = "HackGen35 Console NF";
        font_fallbacks = [ "monospace" ];
        font_features = null;
        font_size = null;
        line_height = "comfortable";
        option_as_meta = false;
        button = false;
        shell = "system";
        # shell = {
        #   program = "zsh";
        # };
        toolbar = {
          title = true;
        };
        working_directory = "current_project_directory";
      };

      lsp = {
        rust-analyzer = {
          binary = {
            # path = lib.getExe pkgs.rust-analyzer;
            path_lookup = true;
          };
          initialization_options = {
            # 保存時のチェックを cargo check ではなく clippy で行う
            check.command = "clippy";
          };
        };

        basedpyright = {
          settings = {
            basedpyright.analysis = {
              # 既定の "recommended" は厳しすぎるので標準的なレベルにする
              typeCheckingMode = "standard";
            };
          };
        };

        tinymist = {
          initialization_options = {
            # バックグラウンドでライブプレビューサーバを起動する
            # (タスク「Typst: ライブプレビューを開く」でブラウザから見る)
            preview.background = {
              enabled = true;
              args = [
                "--data-plane-host=${typstPreviewHost}"
                "--invert-colors=never"
              ];
            };
          };
          settings = {
            formatterMode = "typstyle";
          };
        };

        nix = {
          binary = {
            path_lookup = true;
          };
        };

        elixir-ls = {
          binary = {
            path_lookup = true;
          };
          settings = {
            dialyzerEnabled = true;
          };
        };
      };

      languages = {
        Python = {
          # インデントにタブは使えない (PEP 8)
          hard_tabs = false;
          tab_size = 4;
          code_actions_on_format = {
            "source.organizeImports.ruff" = true;
          };
        };
        # レイアウト規則があるのでタブは不可 (GHC が -Wtabs で警告する)
        Haskell = {
          hard_tabs = false;
          tab_size = 2;
        };
        Go = {
          code_actions_on_format = {
            "source.organizeImports" = true;
          };
        };
      };

      vim_mode = true;
      hard_tabs = true;

      # Tell Zed to use direnv and direnv can use a flake.nix environment
      load_direnv = "shell_hook";
      base_keymap = "VSCode";

      theme = {
        mode = "dark";
        light = "One Light";
        dark = "One Dark";
      };
      icon_theme = "Zed (Default)";

      show_whitespaces = "all";
      ui_font_size = 16;
      buffer_font_size = 15;
      buffer_font_family = "HackGen35 Console NF";
      buffer_font_fallbacks = [
        "Monaco"
        "Courier New"
        "monospace"
      ];
    };
  };
}
