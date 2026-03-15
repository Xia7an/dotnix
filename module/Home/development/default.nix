# Development-related modules
# rider.nix は Atropos 固有のため hosts/Atropos/home.nix でインポートする
{
  imports = [
    ./general.nix
    ./git.nix
    ./direnv.nix
    ./rust.nix
    ./dev-tools.nix
    ./dev-apps.nix
    ./biome.nix
  ];
}
