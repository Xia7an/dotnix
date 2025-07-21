{ config, pkgs, lib, ... }: {
  # Sunshineを有効化
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };

  # OpenGLの有効化（NVENCなど使う場合も含む）
  hardware.opengl = {
    enable = true;
  };

  # XDG Desktop Portal（Waylandサポート用）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}

