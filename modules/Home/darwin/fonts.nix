{ pkgs, ... }: {
  # macOS 用フォント (Home Manager 経由)
  home.packages = with pkgs; [
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    hackgen-nf-font
    source-han-sans
    source-han-serif
    nerd-fonts._0xproto
    rounded-mgenplus
    nerd-fonts.jetbrains-mono
  ];
}