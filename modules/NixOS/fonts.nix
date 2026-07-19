{ pkgs, ... }: {
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
    fontconfig.enable = true;
    fontDir.enable = true;
  };
}
