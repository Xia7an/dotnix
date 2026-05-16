{ pkgs, ... }: {
  home.packages = with pkgs; [
    deno
    bun
    biome
  ];
}
