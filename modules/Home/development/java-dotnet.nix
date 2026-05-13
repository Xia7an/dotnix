{ pkgs, ... }: {
  home.packages = with pkgs; [
    openjdk21
    dotnet-sdk_8
  ];
}