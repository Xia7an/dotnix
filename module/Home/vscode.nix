{pkgs, ...}:{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
  xdg.desktopEntries.vscode-wayland = {
    name = "Visual Studio Code (Wayland)";
    exec = "${pkgs.vscode}/bin/code --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=1";
    icon = "code";
    categories = [ "Development" "IDE" ];
    terminal = false;
  };
}
