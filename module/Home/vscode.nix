{pkgs, ...}:{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
  xdg.desktopEntries.vscode-wayland = {
    name = "Visual Studio Code (Wayland)";
    exec = "${pkgs.vscode}/bin/code --ozone-platform=auto --enable-wayland-ime";
    icon = "code";
    categories = [ "Development" "IDE" ];
    terminal = false;
  };
}
