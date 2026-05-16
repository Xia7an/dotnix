{ pkgs, ... }: {
  # fish シェルを有効化
  # NixOS 側で users.users.<name>.shell = pkgs.fish として設定済み
  programs.fish = {
    enable = true;
    shellAliases = {
      cat  = "bat";
      grep = "rg";
      ls   = "eza --icons always --classify always";
      la   = "eza --icons always --classify always --all";
      ll   = "eza --icons always --long --all --git";
      tree = "eza --icons always --classify always --tree";
      l    = "ls -la";
      zj   = "zellij";
    };
    shellInit = ''
      # PATH additions
      fish_add_path /Users/inoyu/.local/bin
      fish_add_path /Users/inoyu/.lmstudio/bin
      fish_add_path /Users/inoyu/.antigravity/antigravity/bin

      # zoxide integration
      zoxide init fish | source
    '';
    shellAbbrs = {
      cduniv = "cd ~/Documents/大学/授業/3年前期/";
    };
    functions = {
      ya = {
        body = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };
    };
  };
  home.sessionVariables = {
    UNIV = "$HOME/Documents/大学/授業/3年前期/";
  };
}
