{pkgs, inputs, ...} : {
  virtualisation.docker.enable = true;
  users.users.inoyu.extraGroups = [ "docker" ];
}
