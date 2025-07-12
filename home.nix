{
  imports = [
    ./module/Home/chrome.nix
    ./module/Home/git.nix
    ./module/Home/kitty.nix
    ./module/Home/zsh.nix
    ./module/Home/development.nix
    ./module/Home/Hyprland.nix
  ];
  home = rec { # recでAttribute Set内で他の値を参照できるようにする
    username="inoyu";
    homeDirectory = "/home/${username}"; # 文字列に値を埋め込む
    stateVersion = "25.05";
  };
  programs.home-manager.enable = true; # home-manager自身でhome-managerを有効化
}
