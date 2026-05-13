{ ... }: {
  # Ice は大半が UserDefaults に入るため、持ち運べるスカラー設定だけを宣言する。
  # 見た目の詳細はバイナリ plist データを含むため、ここでは安全に扱える項目に絞る。
  targets.darwin.defaults."com.jordanbaird.Ice" = {
    AutoRehide = false;
    CanToggleAlwaysHiddenSection = true;
    CustomIceIconIsTemplate = false;
    EnableAlwaysHiddenSection = false;
    HideApplicationMenus = true;
    IceBarLocation = 1;
    ItemSpacingOffset = 12.0;
  };
}
