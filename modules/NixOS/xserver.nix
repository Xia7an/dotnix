{ ... }: {
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout  = "jp";
    variant = "";
  };
}
