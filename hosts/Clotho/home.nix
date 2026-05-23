{ ... }:
{
  imports = [
    ../../home.nix
    ../../modules/Home/shell/fish.nix
    ../../modules/Home/shell/starship.nix
    ../../modules/Home/shell/zsh.nix
    ../../modules/Home/shell/tmux.nix
    ../../modules/Home/shell/git.nix
    ../../modules/Home/shell/opencode.nix
    ../../modules/Home/terminal/ghostty.nix
    ../../modules/Home/editor/neovim.nix
    ../../modules/Home/editor/vscode.nix
    ../../modules/Home/development/git.nix
    ../../modules/Home/development/direnv.nix
    ../../modules/Home/development/rust.nix
    ../../modules/Home/development/cpp.nix
    ../../modules/Home/development/go.nix
    ../../modules/Home/development/zig.nix
    ../../modules/Home/development/js-ts.nix
    ../../modules/Home/development/python.nix
  ];

  home = {
    username = "inoyu";
    homeDirectory = "/home/inoyu";
    stateVersion = "25.11";
  };
}
