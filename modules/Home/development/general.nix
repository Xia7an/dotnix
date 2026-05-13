{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    go
    deno
    bun
    zig
  ];
}
