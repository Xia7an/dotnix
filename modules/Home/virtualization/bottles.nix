{ pkgs, ... }: {
  home.packages = with pkgs; [ bottles ];
  dconf.enable = true;
}
