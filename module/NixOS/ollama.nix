{ config, lib, pkgs, ... }: {
    services.ollama = {
    enable = true;
    acceleration = "cuda";
    package = pkgs.ollama.override { acceleration = "cuda"; };
    port = 11434;
    host = "0.0.0.0";
    openFirewall = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
    };
}