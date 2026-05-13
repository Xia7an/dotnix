{ pkgs, ... }: {
  # 基本 CLI ユーティリティ
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    fzf
    jq
    zoxide
    bottom
    wget
    curl
    p7zip
    lhasa
    fastfetch
    nyancat
    sl
    yt-dlp
    rtmpdump
    winetricks
  ];
}