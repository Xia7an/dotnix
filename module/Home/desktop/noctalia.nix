{ config, pkgs, inputs, ... }:
{
  # Noctalia Home Manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;

    # Use the package from the Noctalia flake input (recommended in upstream docs)
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Manage startup with Home Manager (do not enable the same service in NixOS module)
    systemd.enable = true;

    settings = {
      wallpaper = {
        enabled = false;
      };
      bar = {
        density = "default";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          center = [
            {
              colorizeIcons = false;
              hideMode = "visible";
              iconScale = 0.8;
              id = "Taskbar";
              onlyActiveWorkspaces = false;
              onlySameOutput = true;
              showPinnedApps = true;
              showTitle = true;
              smartWidth = true;
              titleWidth = 120;
            }
          ];
          right = [
            {
              drawerEnabled = false;
              id = "Tray";
            }
            {
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "Volume";
              displayMode = "alwaysShow";
            }
            {
              formatHorizontal = "HH:mm:ss";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };

      colorSchemes.predefinedScheme = "Dracula";

      general = {
        avatarImage = "${config.home.homeDirectory}/.face";
        radiusRatio = 0.2;
      };

      location = {
        monthBeforeDay = true;
        name = "Marseille, France";
      };
    };
    # settings can also be a JSON string/path in Noctalia module.
  };
}