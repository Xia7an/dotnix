{ config, ... }:
let
  pwd = "${config.home.homeDirectory}/dotnix";
in
{
  inherit pwd;
}
