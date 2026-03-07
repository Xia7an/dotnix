{ ... } : {
  programs.tmux-nix = {
    enable = true;
    keymaps = {
      pane = {
        left.key = "h";
        right.key = "l";
        up.key = "k";
        down.key = "j";
      };
      resize = {
        left.key = "H";
        right.key = "L";
        up.key = "K";
        down.key = "J";
      };
    };
  };
}

