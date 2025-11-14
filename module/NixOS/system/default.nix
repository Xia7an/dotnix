# System-level services and utilities
{
  imports = [
    ./utils.nix
    ./docker.nix
    # ./qemu.nix
    ./sunshine.nix
    ./parsec.nix
    # ./ollama.nix cudaが壊れてるらしいから一時的にコメントアウト
    ./gemini.nix
    ./copilotcli.nix
    # ./stock-ticker.nix
    ./wine.nix
  ];
}
