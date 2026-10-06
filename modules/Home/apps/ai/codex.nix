{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  # Herdr がプロセス名に依存せず Codex と判定できるよう hint を渡す。
  codexWithHerdrHint = pkgs.writeShellApplication {
    name = "codex";
    text = ''
      export HERDR_AGENT=codex
      exec ${lib.getExe codexPackage} "$@"
    '';
  };

  # CLI は両 OS とも flake.lock で固定。ラッパーで上流の補完も失わない。
  codex = pkgs.symlinkJoin {
    name = "codex-with-herdr-hint";
    paths = [
      codexWithHerdrHint
      codexPackage
    ];
    meta.mainProgram = "codex";
  };
in
{
  home.packages = [
    codex
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # GUI と同じ版が必要な場合だけ明示的に選ぶ。通常の codex は GUI に依存しない。
    (pkgs.writeShellApplication {
      name = "codex-bundled";
      text = ''
        export HERDR_AGENT=codex
        exec ${lib.getExe pkgs.python3} ${./codex-app-launcher.py} "$@"
      '';
    })
  ];
}
