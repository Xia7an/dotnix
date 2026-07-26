# Application modules
# Steam は NixOS レベルで管理する (modules/NixOS/apps/gaming.nix)
{
  imports = [
    ./browser/chrome.nix
    ./browser/vivaldi.nix
    ./communication/discord.nix
    ./communication/nextcloud.nix
    ./communication/slack.nix
    ./communication/thunderbird.nix
    ./creative/blender.nix
    ./creative/musescore.nix
    ./document/mupdf.nix
    ./document/notion.nix
    ./document/obsidian.nix
    ./document/okular.nix
    ./document/pdf.nix
    ./explorer/dolphin.nix
    ./explorer/nautilus.nix
    ./media/multimedia.nix
    ./media/spotify.nix
    ./media/vlc.nix
    ./utility/bitwarden.nix
    ./utility/screenshot.nix
    ./utility/stock-ticker.nix
    ./utility/system-tools.nix
    ./vdesktop/immersed.nix
    ./vdesktop/parsec.nix
    ./vdesktop/tigervnc.nix
  ];
}
