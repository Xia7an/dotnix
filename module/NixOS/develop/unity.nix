{pkgs, pkgs-stable, ...} : {
  environment.systemPackages = with pkgs; [
    pkgs-stable.unityhub
  ];
}
