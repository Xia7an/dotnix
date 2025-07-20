{
  pkgs,
  config,
  ...

}:
let
  pwd = (import ./pwd.nix { inherit config; }).pwd;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      deno
      gnumake
      nodejs
      tree-sitter
      imagemagick
      deno
      nodejs-slim
      tree-sitter
      bash-language-server
      clang-tools
      cmake-language-server
      matlab-language-server
      csharp-ls
      dockerfile-language-server-nodejs
      efm-langserver
      haskell-language-server
      haskellPackages.lsp
      lua-language-server
      nil
      nixpkgs-fmt
      nixpkgs-lint
      nodePackages.eslint
      nodePackages.prettier
      # pyright
      python312Packages.debugpy
      python312Packages.jedi-language-server
      ruff
      rust-analyzer
      glsl_analyzer
      shellcheck
      stylelint-lsp
      stylua
      tailwindcss-language-server
      taplo
      texlab
      tinymist
      typescript-language-server
      typstyle
      vim-language-server
      vscode-langservers-extracted
      yaml-language-server
      yamlfmt
      yamllint
    ];
    plugins = with pkgs.vimPlugins; [ 
    lazy-nvim 
    # UI
    lualine-nvim
    tokyonight-nvim

    # File explorer
    neo-tree-nvim

    # Git
    gitsigns-nvim
    vim-fugitive

    # LSP
    nvim-lspconfig
    mason-nvim

    # Completion
    nvim-cmp
    #LuaSnip
    cmp_luasnip
    cmp-nvim-lsp

    # Treesitter
    nvim-treesitter.withAllGrammars

    # Finder
    telescope-nvim

    # Utilities
    trouble-nvim
    noice-nvim
    which-key-nvim
    ];
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/inoyu/dotnix/config/nvim";
  };
}
