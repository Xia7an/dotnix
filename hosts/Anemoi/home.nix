# Anemoi ホスト固有の Home Manager 設定
# 共通設定は home.nix に記述されている
{ ... }:
{
  imports = [
    # 共通 Home Manager 設定
    ../../home.nix
  ];
}
