{ config, lib, pkgs, ... }: {
  warnings = lib.optional (config.networking.hostName != "Atropos")
    "ollama module imported on non-Atropos host (${config.networking.hostName}) - this may not be intended";

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    package = pkgs.ollama.override { acceleration = "cuda"; };
    port = 11434;
    host = "0.0.0.0";
    openFirewall = true;
  };
}
