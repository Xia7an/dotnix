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
    };
  };
}
