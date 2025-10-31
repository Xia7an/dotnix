# /home/inoyu/dotnix/module/NixOS/windows/bottles.nix
{ pkgs, ... }:

{
  # Bottlesをシステムにインストールします。
  environment.systemPackages = with pkgs; [
    bottles
  ];

  # Bottlesが正しく動作するためにDConfを有効化します。
  # これにより、UIのタブが切り替えられない問題などを防ぎます。
  programs.dconf.enable = true;
}
