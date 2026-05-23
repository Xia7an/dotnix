{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      hackgen-nf-font
    ];
    fontDir.enable = true;
  };
}
