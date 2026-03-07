# Application modules
# Steam は NixOS レベルで管理する (module/NixOS/apps/gaming.nix)
{
  imports = [
    ./chrome.nix
    ./vivaldi.nix
    ./discord.nix
  ];
}
