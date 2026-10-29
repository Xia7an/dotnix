{ inputs, pkgs, ... }:
{
  programs.home-manager.enable = true;

  # unfree パッケージをどこでも使えるようにする。
  # - nix run / nix shell nixpkgs#... : ユーザーのレジストリを unfree 許可済みの nixpkgs に向ける
  #   (home-manager だけのホストにも効かせるため、システム側とは別にここでも設定する)
  # - nix-shell -p など flake 外の評価: ~/.config/nixpkgs/config.nix
  nix.registry.nixpkgs.to = {
    type = "path";
    path = import ./lib/nixpkgs-unfree.nix {
      inherit pkgs;
      inherit (inputs) nixpkgs;
    };
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
