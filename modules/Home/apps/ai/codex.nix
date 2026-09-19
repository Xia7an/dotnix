{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  codexAppExecutable = "/Applications/ChatGPT.app/Contents/Resources/codex";
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  codexExecutable = if isDarwin then codexAppExecutable else "${codexPackage}/bin/codex";

  # codex は最終的に `codex-raw` として実行される。
  # Herdr はプロセス名だけではこれを Codex と判定できないため、Herdr が
  # macOS/Linux のプロセス環境から読む公式の foreground-process hint を渡す。
  codexWithHerdrHint = pkgs.writeShellApplication {
    name = "codex";
    text = ''
      export HERDR_AGENT=codex
      ${lib.optionalString isDarwin ''
        if [[ ! -x ${lib.escapeShellArg codexAppExecutable} ]]; then
          printf '%s\n' ${lib.escapeShellArg "error: ChatGPT.app の内蔵 Codex が見つかりません: ${codexAppExecutable}"} >&2
          exit 1
        fi
      ''}
      exec ${lib.escapeShellArg codexExecutable} "$@"
    '';
  };
in
{
  home.packages = [
    codexWithHerdrHint
  ];
}
