{ pkgs, ... }: {
  home.packages = with pkgs; [
    wireguard-tools
    wireshark
    inetutils
    nmap
    dnsutils
  ];
}