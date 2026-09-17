{
  lib,
  pkgs,
  ...
}:
{
  programs.bash = {
    enable = true;

    # Bash itself is provided by the host OS. Home Manager only manages its
    # startup files, so the Nix-provided Bash is not added to the user profile.
    package = null;

    initExtra = lib.mkAfter ''
      # Keep the OS-provided Bash as the login shell, but hand interactive
      # terminal and SSH sessions over to the Home Manager-managed Fish.
      # Non-interactive SSH commands and an explicitly nested Bash are left alone.
      if [[ $- == *i* && -z "''${BASH_EXECUTION_STRING:-}" && -z "''${DOTNIX_KEEP_BASH:-}" ]]; then
        parent_command="$(${pkgs.procps}/bin/ps -o comm= -p "$PPID" 2>/dev/null || true)"
        if [[ "$parent_command" != *fish* ]]; then
          exec ${pkgs.fish}/bin/fish
        fi
        unset parent_command
      fi
    '';
  };
}
