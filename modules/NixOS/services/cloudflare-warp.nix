{ ... }:
{
  services.cloudflare-warp = {
    enable = true;

    # WARP makes outbound connections, so no inbound firewall port is needed.
    openFirewall = false;
  };
}
