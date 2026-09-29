{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  # Herdr がプロセス名に依存せず Codex と判定できるよう hint を渡す。
  codexWithHerdrHint = pkgs.writeShellApplication {
    name = "codex";
    text = ''
      export HERDR_AGENT=codex
      ${
        if isDarwin then
          # GUI は Homebrew 管理。自己更新で変わる内部パスは起動時に解決する。
          ''exec ${lib.getExe pkgs.python3} ${./codex-app-launcher.py} "$@"''
        else
          ''exec ${lib.escapeShellArg "${codexPackage}/bin/codex"} "$@"''
      }
    '';
  };
in
{
  home.packages = [
    codexWithHerdrHint
  ];
}
