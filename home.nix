{
  imports = [
    ./module/chrome.nix
    ./module/git.nix
    ./module/kitty.nix
    ./module/zsh.nix
    ./module/development.nix
  ];
  home = rec { # recでAttribute Set内で他の値を参照できるようにする
    username="inoyu";
    homeDirectory = "/home/${username}"; # 文字列に値を埋め込む
    stateVersion = "25.05";
  };
  programs.home-manager.enable = true; # home-manager自身でhome-managerを有効化
}
