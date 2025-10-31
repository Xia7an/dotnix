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
