{ nixpkgs, system, overlays }:
import nixpkgs {
  inherit system overlays;
  config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "openssl-1.1.1w" ];
  };
}
