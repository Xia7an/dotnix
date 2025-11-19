{ pkgs, ... }: {
  # fish シェルを有効化
  programs.fish = {
    enable = true;
  };


  # fish をデフォルトシェルとして使う場合は、
  # NixOS 側で users.users.<name>.shell = pkgs.fish; を設定済み
}
