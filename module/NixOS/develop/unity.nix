{pkgs, ...} : {
  environment.systemPackages = with pkgs; [
    unityhub
    jetbrains.rider
  ];
}
