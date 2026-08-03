{ pkgs, ... }: {
  home.packages = with pkgs; [
    # docker (docker_28) は 2025-11 以降 unmaintained で insecure 扱いのため docker_29 を使う。
    docker_29
    docker-compose
  ];
}
