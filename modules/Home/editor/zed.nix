{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # Typst プレビューペイン入りのパッチ済み Zed と、その言語サーバー兼レンダラ (Xia7an/zed-typst-preview)
  tlp = inputs.zed-typst-preview.packages.${pkgs.stdenv.hostPlatform.system};
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.zed-typst-preview.homeManagerModules.default ];

  programs.typst-livepreview.enable = true;
  programs.zed-editor = {
    enable = true;
    # Linux ではパッチ済み Zed は未検証なので、Mac だけ差し替える
    package = if isDarwin then tlp.zed-editor else pkgs.unstable.zed-editor;

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

      # エージェントパネルの外部エージェント (ACP)。
      # レジストリ版は npx 等で自動ダウンロードされるので、Nix のバイナリを直接指定する。
      # 認証はそれぞれの CLI と共有 (~/.claude, ~/.config/opencode)。
      agent_servers = {
        "Claude Code" = {
          type = "custom";
          # llm-agents の claude-code を CLAUDE_CODE_EXECUTABLE に設定済みのラッパー
          command = lib.getExe llmAgents.claude-agent-acp;
        };
        "OpenCode" = {
          type = "custom";
          command = lib.getExe llmAgents.opencode;
          args = [ "acp" ];
        };
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
          settings = {
            formatterMode = "typstyle";
          };
        };

        # Zed 内のプレビューペイン用 (補完・診断は tinymist、プレビューだけこちら)
        typst-livepreview = lib.mkIf isDarwin {
          binary.path = lib.getExe tlp.typst-livepreview;
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
