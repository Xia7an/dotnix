# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware/Atropos-SSD-hardware.nix
      ./module/NixOS/desktop
      ./module/NixOS/develop
      ./module/NixOS/utils.nix
      ./module/NixOS/Sunshine.nix
      ./module/NixOS/gaming.nix
      ./module/NixOS/gemini.nix
      ./module/NixOS/ollama.nix
      ./module/NixOS/dolphin.nix
      ./module/NixOS/docker.nix
      ./module/NixOS/parsec.nix
      ./module/NixOS/blender.nix
      ./module/NixOS/stock-ticker.nix
      ./module/NixOS/windows
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.theme = ./misc/Vimix;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "inoyu" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;  # see the note above

  networking.hostName = "Atropos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  networking.interfaces."wlp3s0" = {
    ipv4.addresses = [{
      address = "192.168.10.10"; # 利便性のため静的IPを要求
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = {
    interface = "wlp3s0";
    address = "192.168.10.1"; # おうちのルーターのアドレス
  };
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  networking = {
    wireless.enable = true;
    wireless.secretsFile = "/home/inoyu/secrets/wireless.conf"; # 中身は psk=おうちwifiのpassword
    wireless.networks."aterm-b43571-a" = {
      pskRaw = "ext:psk";
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  fonts = {
    fonts = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      #noto-fonts-emoji
      hackgen-nf-font
      rounded-mgenplus
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP" "Noto Color Emoji"];
        sansSerif = ["Noto Sans CJK JP" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Configure keymap in X11
  #services.xserver.xkb = {
  #  layout = "jp";
  #  variant = "";
  #};
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "inoyu";
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.inoyu = {
    isNormalUser = true;
    description = "Inoyu";
    extraGroups = [ "networkmanager" "wheel" "docker" "storage"];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "inoyu";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  eza
  bat
  ripgrep
  zsh-powerlevel10k
  sunshine
  gcc
  libgcc
  gnumake
  cmake
  extra-cmake-modules
  nvtopPackages.nvidia
  pciutils
  nodejs
  ];

  services.openssh.enable = true;

  services.tailscale.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs = {
    git = {
      enable = true;
    };
    zsh = {
      enable = true;
      promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/.p10k.zsh
      '';
    };
  };


  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
    allowedUDPPorts = [config.services.tailscale.port];
    trustedInterfaces = ["tailscale0"];
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
