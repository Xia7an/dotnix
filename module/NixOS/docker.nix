{config, pkgs, inputs, ...} : {
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.docker.daemon.settings = {
    runtimes = {
      nvidia = {
        path = "nvidia-container-runtime";
      };
    };
  };
}
