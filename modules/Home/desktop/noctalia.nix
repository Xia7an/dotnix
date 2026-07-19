{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Noctalia Home Manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf pkgs.stdenv.isLinux {
    programs.noctalia-shell = {
      enable = true;

      # Use the package from the Noctalia flake input (recommended in upstream docs)
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

      settings = {
        wallpaper = {
          enabled = false;
        };
        bar = {
          density = "default";
          position = "bottom";
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

        colorSchemes = {
          useWallpaperColors = true;
          predefinedScheme = "Dracula";
          darkMode = false;
          schedulingMode = "off";
          generationMethod = "tonal-spot";
          monitorForColors = "";
          syncGsettings = true;
        };

        general = {
          avatarImage = "${config.home.homeDirectory}/.face";
          radiusRatio = 0.2;
        };

        location = {
          monthBeforeDay = true;
          name = "Tokyo, Japan";
        };
      };
    };
  };
}
