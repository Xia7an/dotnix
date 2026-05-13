# Windows integration modules
# winapps は Linux/QEMU 向け。macOS ではスキップする
{ ... }: {
  imports = [ ./winapps.nix ];
}
