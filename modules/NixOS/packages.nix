{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    eza
    bat
    ripgrep
  ];
}
