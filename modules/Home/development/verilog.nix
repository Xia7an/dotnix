{ pkgs, ... }:
{
  home.packages = with pkgs; [
    iverilog
    gtkwave
  ];
}
