{ pkgs, ... }: {
  # fish シェルを有効化
  programs.fish = {
    enable = true;
  };

  # Starship プロンプトを有効化
  programs.starship = {
    enable = true;
    # 必要に応じてカスタム設定を追加
    # settings = { ... };
  };

  # fish をデフォルトシェルとして使う場合は、
  # NixOS 側で users.users.<name>.shell = pkgs.fish; を設定済み
}
