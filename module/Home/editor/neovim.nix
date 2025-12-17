{pkgs, config, ...} : 
let
  pwd = (import ../development/pwd.nix { inherit config; }).pwd;
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Neovim が必要とする外部ツールだけ
    extraPackages = with pkgs; [
      # LSP
      lua-language-server
      nil

      # Formatter
      stylua
      nixpkgs-fmt

      # Linter
      statix

      # Utilities
      ripgrep
      fd
      lazygit
      git
    ];

    # プラグインは lazy.nvim のみ
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };
   xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${pwd}/nvim";
    recursive = true;
  };
}