{ pkgs, ... }:

let
  # DiscordにWayland用の引数を付けてラップする
  discord-wayland = pkgs.symlinkJoin {
    name = "discord-wayland";
    paths = [ pkgs.discord ]; # 元になるパッケージは `pkgs.discord`
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/discord \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform-wayland" \
        --add-flags "--enable-wayland-ime"
    '';
  };

in
{
  # home.packages に追加してインストールする
  home.packages = [
    discord-wayland
    # ... 他のパッケージ
  ];
}
