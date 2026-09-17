{ homeManagerConfig, username, ... }: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = homeManagerConfig.programs.fish.package;
    packages = [ ];
  };
  services.getty.autologinUser = username;
  programs.fish.enable = true;
  programs.fish.package = homeManagerConfig.programs.fish.package;
}
