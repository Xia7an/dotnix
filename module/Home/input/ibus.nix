{ config, pkgs, ... }:

{
  # 1. XKB カスタムマッピング（変換 / 無変換 を正しく割り当て）
  xsession.enable = true;
  xsession.xkb = {
    layout = "jp";
    model = "pc105";
    options = [];

    # 変換キー(Henkan) → Henkan_Mode
    # 無変換キー(Muhenkan) → Muhenkan
    extraLayouts = {
      jp_custom = {
        description = "JP keyboard with explicit Henkan/Muhenkan mapping";
        languages = [ "jpn" ];
        symbolsFile = pkgs.writeText "jp_custom" ''
          xkb_symbols "basic" {
            include "jp(basic)"

            key <HENK> { [ Henkan_Mode ] };
            key <MUHE> { [ Muhenkan   ] };
          };
        '';
      };
    };

    layout = "jp_custom";
  };

  # 2. evdev レベルで補正したい場合は keyd を使用
  services.keyd = {
    enable = true;

    # /etc/keyd/default.conf が生成される
    config = ''
      [ids]
      *
      
      [main]
      henkan = henkan
      muhenkan = muhenkan
    '';
  };

  # 3. niri を使う場合の推奨設定
  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb_layout = "jp_custom";
          xkb_model = "pc105";
        };
      };
    };
  };
}
