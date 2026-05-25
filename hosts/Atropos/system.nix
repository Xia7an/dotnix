{ config, pkgs, inputs, ... }: {
  imports = [
    ../../modules/NixOS/locale.nix
    ../../modules/NixOS/fonts.nix
    ../../modules/NixOS/users.nix
    ../../modules/NixOS/packages.nix
    ../../modules/NixOS/nix.nix
    ../../modules/NixOS/xserver.nix
    ../../modules/NixOS/git.nix
    ../../modules/NixOS/desktop/gdm.nix
    ../../modules/NixOS/services/openssh.nix
    ../../modules/NixOS/services/tailscale.nix
    ../../hardware/Atropos-SSD-hardware.nix
    ../../modules/NixOS/desktop/nvidia.nix
    ../../modules/NixOS/security.nix
    ../../modules/NixOS/nix-ld.nix
    ../../modules/NixOS/apps/ollama.nix
  ];

  boot.loader.grub = {
    enable              = true;
    device              = "nodev";
    useOSProber         = true;
    efiSupport          = true;
    efiInstallAsRemovable = true;
    theme               = ../../misc/Vimix;
  };
  boot.kernelModules      = [ "kvm-intel" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName           = "Atropos";
  networking.networkmanager.enable = false;
  networking.useNetworkd        = true;
  networking.interfaces."wlp3s0".ipv4.addresses = [{
    address      = "192.168.10.10";
    prefixLength = 24;
  }];
  networking.defaultGateway = {
    interface = "wlp3s0";
    address   = "192.168.10.1";
  };
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  networking.wireless = {
    enable      = true;
    secretsFile = "/home/inoyu/secrets/wireless.conf";
    networks."aterm-b43571-a".pskRaw = "ext:psk";
  };

  networking.firewall = {
    enable           = true;
    allowedTCPPorts  = [ 22 3389 ];
    allowedUDPPorts  = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  users.users.inoyu.extraGroups =
    [ "networkmanager" "wheel" "docker" "storage" ];

  services.displayManager.autoLogin = { enable = true; user = "inoyu"; };

  fonts.packages = with pkgs; [
    twitter-color-emoji
    source-han-sans
    source-han-serif
    jetbrains-mono
    nerd-fonts._0xproto
    orbitron
    rounded-mgenplus
  ];
  fonts.fontconfig.defaultFonts = {
    serif     = [ "Noto Serif CJK JP"  "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans CJK JP"   "Noto Color Emoji" ];
    monospace = [ "HackGen Console NF" "Noto Color Emoji" ];
    emoji     = [ "Noto Color Emoji" ];
  };

  system.stateVersion = "25.05";
}
