{ config, pkgs, inputs, ... }: {
  imports = [
    ../common/nixos.nix
    ../../hardware/Nyx-hardware.nix
    ../../modules/NixOS/desktop
    ../../modules/NixOS/system
  ];

  boot.loader.grub = {
    enable      = true;
    device      = "/dev/sda";
    useOSProber = true;
  };

  networking.hostName              = "Nyx";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000;  to = 8010;  }
    ];
    allowedUDPPorts  = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  users.users.inoyu.extraGroups = [ "networkmanager" "wheel" ];

  fonts.packages = with pkgs; [
    noto-fonts-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    serif     = [ "Noto Serif CJK JP"   "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans CJK JP"    "Noto Color Emoji" ];
    monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
    emoji     = [ "Noto Color Emoji" ];
  };

  services.sunshine = {
    enable    = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  i18n.inputMethod = {
    enabled      = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
  };

  programs.zsh = {
    enable     = true;
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/.p10k.zsh
    '';
  };

  environment.systemPackages = with pkgs; [
    zsh-powerlevel10k
    sunshine
  ];

  system.stateVersion = "25.05";
}
