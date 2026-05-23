{ config, pkgs, inputs, ... }: {
  imports = [
    ../common/nixos.nix
    ../../hardware/anemoi.nix
    ../../modules/NixOS/networkmanager.nix
    ../../modules/NixOS/desktop
    ../../modules/NixOS/desktop/sunshine.nix
    ../../modules/NixOS/system/bluetooth.nix
    ../../modules/NixOS/apps
  ];

  boot.loader.grub = {
    enable              = true;
    device              = "nodev";
    useOSProber         = true;
    efiSupport          = true;
    efiInstallAsRemovable = true;
    theme               = ../../misc/Vimix;
  };
  boot.kernelPackages = pkgs.linuxPackages_6_12;

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
