{pkgs, config, ...} : {
  environment.systemPackages = with pkgs; [
    qtrvsim
  ];
}
