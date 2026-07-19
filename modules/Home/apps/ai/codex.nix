{ config, pkgs, lib, ... }:

let
  codexPkg =
    if pkgs ? codex then
      pkgs.codex
    else
      pkgs.writeShellApplication {
        name = "codex";
        runtimeInputs = [ pkgs.nodejs ];
        text = ''
          exec npx -y @openai/codex "$@"
        '';
      };
in
{
  home.packages = [
    codexPkg
  ];

  home.file.".codex/config.toml".text = ''
    # 既定モデル
    model = "gpt-5.5"
  '';
}
