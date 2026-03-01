{pkgs, pkgs-stable, ...} : {
  environment.systemPackages = with pkgs; [
    unityhub
  ];
}
