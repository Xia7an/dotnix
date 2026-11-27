{ pkgs, lib, ... }: {
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      hackgen-nf-font
      (pkgs.texlive.withPackages (ps: [
        ps.haranoaji
      ]))
    ];
    fontconfig = {
      enable = true;
      # ホスト側 (Atropos など) で上書きできるように mkDefault にしておく。
      defaultFonts = {
        sansSerif = lib.mkDefault [
          "Noto Sans CJK JP"
          "Noto Color Emoji"
        ];
        serif = lib.mkDefault [
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        monospace = lib.mkDefault [
          "HackGen Console NF"
          "Noto Color Emoji"
        ];
        emoji = lib.mkDefault [ "Noto Color Emoji" ];
      };
      # system-ui は既定の別名が無く、fontconfig が HackGen (Nerd Font) にフォールバックしていた。
      # Chrome の UI や多くの Web ページが system-ui を使うので、sans-serif と同じにする。
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <alias binding="same">
            <family>system-ui</family>
            <prefer>
              <family>BIZ UDPGothic</family>
              <family>Noto Sans CJK JP</family>
            </prefer>
          </alias>
        </fontconfig>
      '';
    };
    fontDir.enable = true;
  };
}
