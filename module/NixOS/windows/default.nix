# /home/inoyu/dotnix/module/NixOS/windows/default.nix
# このファイルは、windows関連の設定をまとめるためのエントリーポイントです。
# NixOSのメイン設定(configuration.nix)からこのファイルをインポートしてください。
#
# 例:
# imports = [
#   ./hardware-configuration.nix
#   /path/to/dotnix/module/NixOS/windows/default.nix
# ];

{ ... }:

{
  imports =
    [
      # Bottlesの基本設定を読み込みます。
      # ./bottles.nix
      ./winapps.nix
      # --- アプリケーションごとの設定を追加 --- #
      # `apps`ディレクトリ内に特定のアプリケーション用の設定ファイルを作成し、
      # ここでインポートすることで、設定をモジュール化できます。
      #
      # 例:
      # ./apps/photoshop.nix
      # ./apps/steam.nix
    ];
}
