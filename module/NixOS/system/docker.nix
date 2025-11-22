{config, pkgs, inputs, ...} : {
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.docker.daemon.settings = {
    runtimes = {
      nvidia = {
        path = "nvidia-container-runtime";
      };
    };
  };
}
