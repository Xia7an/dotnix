{ inputs, pkgs, ... } : {
  imports = [
    # カテゴリーごとに整理されたモジュール
    ./module/Home/terminal
    ./module/Home/editor
    ./module/Home/desktop
    ./module/Home/apps
    ./module/Home/development
  ];
  
  home = rec { # recでAttribute Set内で他の値を参照できるようにする
    username="inoyu";
    homeDirectory = "/home/${username}"; # 文字列に値を埋め込む
    stateVersion = "25.05";
  };
  
  programs.home-manager.enable = true; # home-manager自身でhome-managerを有効化
}
