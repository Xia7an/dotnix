{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ファイルマネージャー
    yazi

    # 圧縮・解凍
    unzip
    zip

    # エディタ (CLI版)
    helix
    vim

    # 基本 CLI ユーティリティ
    bat
    eza
    fd
    ripgrep
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

    # ネットワークツール
    wireguard-tools
    wireshark
    inetutils
    nmap
    dnsutils
  ];
}
