{pkgs, lib, ... } : {
  programs.zed-editor = {
  enable = true;

  # This populates the userSettings "auto_install_extensions"
  extensions = [ "nix" "toml" "elixir" "make" "html" "python" ];

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
      default_model = {
        provider = "copilot_chat";
        model = "gpt-5-mini";
      };
      model_parameters = [];
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
          directories = [ ".env" "env" ".venv" "venv" ];
          activate_script = "default";
        };
      };
      env = {
        TERM = "alacritty";
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
      "Elixir" = {
        language_servers = [ "!lexical" "elixir-ls" "!next-ls" ];
        format_on_save = {
          external = {
            command = "mix";
            arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ];
          };
        };
      };

      "HEEX" = {
        language_servers = [ "!lexical" "elixir-ls" "!next-ls" ];
        format_on_save = {
          external = {
            command = "mix";
            arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ];
          };
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
    buffer_font_fallbacks = [ "Monaco" "Courier New" "monospace" ];
  };
};
}
