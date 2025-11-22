{
  pkgs,
  config,
  ...

}:
let
  pwd = (import ../development/pwd.nix { inherit config; }).pwd;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil
      # Formatters
      stylua
      nixpkgs-fmt
      # Linters
      statix
      # Other tools
      ripgrep
      fd
      lazygit
    ];
    plugins = with pkgs.vimPlugins; [ 
      # UI
      lualine-nvim
      tokyonight-nvim
      catppuccin-nvim
      nvim-web-devicons
      dressing-nvim
      bufferline-nvim
      indent-blankline-nvim
      mini-nvim

      # File explorer
      neo-tree-nvim
      nui-nvim
      plenary-nvim

      # Editor
      telescope-nvim
      telescope-fzf-native-nvim
      flash-nvim
      which-key-nvim
      gitsigns-nvim
      trouble-nvim
      todo-comments-nvim
      vim-illuminate

      # Git
      vim-fugitive

      # LSP
      nvim-lspconfig
      mason-nvim
      mason-lspconfig-nvim
      neodev-nvim

      # Completion
      nvim-cmp
      luasnip
      friendly-snippets
      cmp_luasnip
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      # Treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects

      # Formatting
      conform-nvim

      # Linting
      nvim-lint

      # Coding
      nvim-autopairs
      comment-nvim
      nvim-ts-context-commentstring
      mini-nvim

      # Utilities
      noice-nvim
      nvim-notify
      toggleterm-nvim
    ];
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config/nvim";
  };
}
