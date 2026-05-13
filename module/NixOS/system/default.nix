# System-level services and utilities
{
  imports = [
    ./bluetooth.nix
    ./utils.nix
    # ./docker.nix
    # ./qemu.nix
    ./sunshine.nix
    ./parsec.nix
    # ./ollama.nix cudaが壊れてるらしいから一時的にコメントアウト
    # ./stock-ticker.nix
  ];
}
