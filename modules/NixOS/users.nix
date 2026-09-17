{ pkgs, username, ... }: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = pkgs.fish;
    packages = [ ];
  };
  services.getty.autologinUser = username;
  programs.fish.enable = true;
}
