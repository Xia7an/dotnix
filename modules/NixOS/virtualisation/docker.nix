{ pkgs, username, ... }:
{
  # Docker デーモン。CLI と docker-compose は Home Manager 側 (modules/Home/virtualization/docker.nix) でも入れている。
  virtualisation.docker = {
    enable = true;
    # docker (docker_28) は 2025-11 以降 unmaintained で insecure 扱いのため docker_29 を使う。
    package = pkgs.docker_29;
  };

  # sudo なしで docker を使えるようにする。
  users.users.${username}.extraGroups = [ "docker" ];
}
