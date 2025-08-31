{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unzip
    zip
    bottom
    yazi
  ];
}
