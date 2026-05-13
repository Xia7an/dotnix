# WinApps — Linux 上で Windows アプリをネイティブ風に実行するためのツール
# RDP 経由で Windows VM に接続する。compose.yml / winapps.conf は
# config/winapps/ ディレクトリで管理する (home-manager 側でリンク済み)
{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    freerdp  # RDP クライアント (winapps の依存)
    inputs.winapps.packages."x86_64-linux".winapps
    inputs.winapps.packages."x86_64-linux".winapps-launcher
  ];
}