{ config, pkgs, inputs, ... }: {
  imports = [
    ../common/nixos.nix
    ../../hardware/anemoi.nix
    # inputs.nixos-hardware.nixosModules.microsoft-surface-common
    ../../modules/NixOS/desktop
    ../../modules/NixOS/system
    ../../modules/NixOS/apps
    ../../modules/NixOS/input
  ];

  boot.loader.grub = {
    enable              = true;
    device              = "nodev";
    useOSProber         = true;
    efiSupport          = true;
    efiInstallAsRemovable = true;
    theme               = ../../misc/Vimix;
  };

  time.hardwareClockInLocalTime = true;

  # hardware.microsoft-surface.kernelVersion = "stable";

  services.iptsd.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  networking.hostName = "Anemoi";
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    "aterm-b43571-a" = {
      connection = {
        id = "aterm-b43571-a";
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        ssid = "aterm-b43571-a";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  system.stateVersion = "25.11";
}
