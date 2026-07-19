{ pkgs, ... }: {
  users.users.inoyu = {
    isNormalUser = true;
    description  = "Inoyu";
    shell        = pkgs.fish;
    packages     = [];
  };
  services.getty.autologinUser = "inoyu";
  programs.fish.enable = true;
}
