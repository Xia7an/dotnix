# System-level services and utilities
{
  imports = [
    ./utils.nix
    ./docker.nix
    ./qemu.nix
    ./sunshine.nix
    ./parsec.nix
    ./ollama.nix
    ./gemini.nix
    ./stock-ticker.nix
    ./wine.nix
  ];
}
