{
  config,
  pkgs,
  lib,
  ...
}:

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
}
