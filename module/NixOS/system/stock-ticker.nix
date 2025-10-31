{ config, pkgs, stock-ticker, ... }:
{
  environment.systemPackages = with pkgs; [
    stock-ticker
    ((pkgs.writeScriptBin "stock-price.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    export PMP_KEY=$(cat ~/secrets/FMP_API_KEY)
    stock-ticker --tickers GOOG
    ''))
  ];
}
