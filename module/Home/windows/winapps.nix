{pkgs, ... } : {
    home.file.".config/winapps" = {
        source = ../../../config/winapps;
        recursive = true;
    };
}