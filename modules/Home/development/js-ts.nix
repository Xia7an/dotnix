{ pkgs, ... }:
{
  home.packages = with pkgs; [
    biome
    mise
  ];

  programs.fish.interactiveShellInit = ''
    if type -q mise
      mise activate fish | source
    end
  '';

  programs.bash.initExtra = ''
    if command -v mise &> /dev/null; then
      eval "$(mise activate bash)"
    fi
  '';

  programs.zsh.initContent = ''
    if command -v mise &> /dev/null; then
      eval "$(mise activate zsh)"
    fi
  '';
}
