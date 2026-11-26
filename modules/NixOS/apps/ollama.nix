{
  config,
  lib,
  pkgs,
  ...
}:
{
  warnings =
    lib.optional (config.networking.hostName != "Atropos")
      "ollama module imported on non-Atropos host (${config.networking.hostName}) - this may not be intended";

  services.ollama = {
    enable = true;
    # CUDA 版は unfree なので cache.nixos.org には無く、stable の ollama を
    # override すると CUDA ツールチェインごと手元でフルビルドになる。
    # 公式 CUDA キャッシュ (cache.nixos-cuda.org) は unstable の ollama-cuda を配布しているのでそちらを使う。
    package = pkgs.unstable.ollama-cuda;
    port = 11434;
    host = "0.0.0.0";
    openFirewall = true;
  };

  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
