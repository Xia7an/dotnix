# karukan (ニューラルかな漢字変換 IME) を fcitx5 で使うための Home Manager モジュール。
#
#   imports = [ ../../modules/Home/input/karukan.nix ];
#   programs.karukan.enable = true;
#
# - fcitx5 アドオンを i18n.inputMethod.fcitx5.addons に追加する
#   (NixOS 側で fcitx5 を有効にしているホストは modules/NixOS/input/karukan.nix を使う)
# - 上流リリースのシステム辞書を ~/.local/share/karukan-im/dict.bin に配置する
# - settings を ~/.config/karukan-im/config.toml に書き出す
#
# 変換モデル (GGUF) は初回起動時に karukan 自身が Hugging Face から
# ~/.cache 以下にダウンロードする。入力メソッドへの追加は fcitx5-configtool で行う。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.karukan;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.karukan = {
    enable = lib.mkEnableOption "karukan Japanese input method for fcitx5";

    package = lib.mkPackageOption pkgs "fcitx5-karukan" { };

    addToFcitx5Addons = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Home Manager の i18n.inputMethod.fcitx5.addons にアドオンを追加する。
        fcitx5 を NixOS 側で管理しているホストでは false にして、
        NixOS モジュールの programs.karukan を使う。
      '';
    };

    dictionary.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "上流リリースのシステム辞書 (dict.bin) を配置する。";
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          conversion = {
            live_conversion = false;
            n_threads = 0;
          };
          symbol.punctuation = "，．";
        }
      '';
      description = ''
        ~/.config/karukan-im/config.toml の内容。空なら書き出さず上流の既定値を使う。
        項目は https://github.com/togatoga/karukan/blob/main/docs/configuration.md を参照。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "programs.karukan は Linux (fcitx5) 専用です。";
      }
    ];

    i18n.inputMethod.fcitx5.addons = lib.mkIf cfg.addToFcitx5Addons [ cfg.package ];

    xdg.dataFile."karukan-im/dict.bin" = lib.mkIf cfg.dictionary.enable {
      source = "${cfg.package.dictionary}/dict.bin";
    };

    xdg.configFile."karukan-im/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "karukan-config.toml" cfg.settings;
    };
  };
}
