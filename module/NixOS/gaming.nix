{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    steam
    # Optional: Lutrisを入れてProton GEを管理
    lutris
  ];
  # 1. プロプライエタリなパッケージを許可
  # Steam, Proton-GE, NVIDIAドライバなどに必要です
  nixpkgs.config.allowUnfree = true;

  # 2. 3Dアクセラレーションと32bitサポート
  # 多くのWindowsゲームで必須です
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # 3. 32bitアプリケーションのオーディオサポート
  hardware.pulseaudio.support32Bit = true;

  # 4. Steam関連のハードウェアサポート
  # SteamコントローラーやVRヘッドセットのためにudevルールなどを設定します
  hardware.steam-hardware.enable = true;

  # 5. Steam本体とProton-GEの導入
  programs.steam = {
    enable = true;
    
    # このオプションがProton-GEを自動的に展開し、
    # Steamが認識できる正しい場所に配置します
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
    
    # (任意) Steam Linkなどの機能を使う場合にファイアウォールを開放します
    remotePlay.openFirewall = true;
  };
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          #migu #ここではmiguをインストールしている
          noto-fonts-cjk-sans
        ];
    };
  };
}
