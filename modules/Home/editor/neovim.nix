{ lib, pkgs, ... }:

let
  # nvim-treesitter は main ブランチに移行済みで、パーサは runtimepath 全体ではなく
  # `install_dir`(既定 ~/.local/share/nvim/site) 直下の parser/ と queries/ しか
  # 見ない (lua/nvim-treesitter/config.lua の get_installed)。
  # nixpkgs の grammar derivation はちょうどこのレイアウト(parser/*.so + queries/<lang>/)
  # で出力されるので、symlinkJoin したものをそのまま install_dir として渡す。
  # これをやらないと LazyVim が「未インストール」と判定して :TSInstall を走らせ、
  # コンパイラとネットワークを要求してしまう。
  treesitterParsers = pkgs.symlinkJoin {
    name = "nvim-treesitter-parsers";
    paths = pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };
in

{
  home.packages = with pkgs; [
    ghostscript
    mermaid-cli
  ];

  programs.neovim = {
    enable = true;
    # プラグインと treesitter パーサを unstable から取るため、本体も unstable に揃える。
    # (programs.neovim.package の既定は pkgs.neovim-unwrapped = stable なので明示が必要)
    package = pkgs.unstable.neovim-unwrapped;

    # mason.nvim を無効化しているぶん、LSP/フォーマッタ/リンタは全て PATH から供給する。
    extraPackages = with pkgs.unstable; [
      # LazyVim 本体
      lua-language-server
      stylua
      shfmt
      # snacks picker / grug-far / LazyVim の git 連携
      ripgrep
      fd
      lazygit
      tree-sitter
      # extras: lang.clangd
      clang-tools
      # extras: lang.docker
      dockerfile-language-server
      docker-compose-language-service
      hadolint
      # extras: lang.nix
      nil
      nixfmt
      statix
      # extras: lang.python
      pyright
      ruff
      # extras: lang.rust
      rust-analyzer
      # extras: lang.typescript (+ biome)
      vtsls
      biome
      # 独自: plugins/image.lua (processor = "magick_cli")
      imagemagick
      # 独自: plugins/typst.lua
      typst
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      # macOS: 独自 plugins/im-select.lua の default_command
      macism
    ];

    # lazy.nvim 本体だけ runtimepath に置き、残りは下の dev.path 経由で読ませる。
    plugins = with pkgs.unstable.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig =
      let
        # 実機 (~/.config/nvim/lazy-lock.json) に入っているプラグインと 1:1 で対応させる。
        # lazy.nvim は spec の名前 (= lazy-lock.json のキー) で dev.path 配下を探すため、
        # linkFarm のエントリ名をその名前に揃える必要がある。
        # lib.getName が期待どおりの名前を返さないもの (catppuccin と mini.nvim 由来の
        # サブモジュール) だけ手で名前を付けている。
        plugins = with pkgs.unstable.vimPlugins; [
          LazyVim
          blink-cmp
          bufferline-nvim
          clangd_extensions-nvim
          claudecode-nvim
          conform-nvim
          crates-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          im-select-nvim
          image-nvim
          lazydev-nvim
          lualine-nvim
          noice-nvim
          nui-nvim
          nvim-lint
          nvim-lspconfig
          nvim-surround
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          nvim-web-devicons
          persistence-nvim
          plenary-nvim
          render-markdown-nvim
          rustaceanvim
          snacks-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          typst-vim
          venv-selector-nvim
          which-key-nvim
          { name = "catppuccin"; path = catppuccin-nvim; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.icons"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
        ];
        mkEntryFromDrv = drv:
          if lib.isDerivation drv then
            { name = "${lib.getName drv}"; path = drv; }
          else
            drv;
        lazyPath = pkgs.unstable.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            -- LazyVim 側のプラグインだけ遅延し、lua/plugins/ の自作 spec は起動時に読む
            -- (LazyVim starter の既定と同じ)
            lazy = false,
          },
          dev = {
            -- pkgs.unstable.vimPlugins.* の実体を再利用する
            path = "${lazyPath}",
            patterns = { "" },
            -- dev.path に無いものだけ GitHub から取得する保険
            fallback = true,
          },
          install = {
            colorscheme = { "tokyonight", "habamax" },
          },
          checker = {
            -- プラグインは flake.lock で固定されており lazy からは更新できないため無効化
            enabled = false,
          },
          rocks = {
            -- luarocks(hererocks) の実行時インストールは再現性を壊すので使わない。
            -- image.nvim は processor = "magick_cli" 運用なので magick rock は不要。
            enabled = false,
          },
          performance = {
            rtp = {
              disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
              },
            },
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },

            -- 実機の ~/.config/nvim/lazyvim.json で有効化されている extras。
            -- lazyvim.json は LazyVim が実行時に書き換えるファイルなので、
            -- nix からは spec に直接 import して宣言的に固定する。
            { import = "lazyvim.plugins.extras.ai.claudecode" },
            { import = "lazyvim.plugins.extras.lang.clangd" },
            { import = "lazyvim.plugins.extras.lang.docker" },
            { import = "lazyvim.plugins.extras.lang.git" },
            { import = "lazyvim.plugins.extras.lang.nix" },
            { import = "lazyvim.plugins.extras.lang.python" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.lang.typescript" },
            { import = "lazyvim.plugins.extras.lang.typescript.biome" },

            -- 以下は LazyVim を nix 上で動かすための調整
            -- mason.nvim は使わず programs.neovim.extraPackages で供給する
            { "mason-org/mason.nvim", enabled = false },
            { "mason-org/mason-lspconfig.nvim", enabled = false },
            -- blink.cmp は nixpkgs 版に Rust 製 fuzzy ライブラリが同梱済み
            {
              "saghen/blink.cmp",
              build = false,
              opts = { fuzzy = { prebuilt_binaries = { download = false } } },
            },

            -- 自作 spec (xdg.configFile."nvim/lua" 経由)
            { import = "plugins" },

            -- treesitter パーサを nix store から供給する。
            -- ensure_installed を潰す代わりに install_dir を差し替えることで、
            -- LazyVim 側の「未インストールなら :TSInstall」判定を満たす。
            -- spec の最後に置いて確実に上書きさせる。
            {
              "nvim-treesitter/nvim-treesitter",
              build = false,
              opts = { install_dir = "${treesitterParsers}" },
            },
          },
        })
      '';
  };

  # LazyVim 標準の設定置き場, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/stylua.toml".source = ./stylua.toml;
}
