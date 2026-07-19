• 移行前バックアップの導線を追加しました。[scripts/darwin-pre-nix-backup.sh](/Users/inoyu/
  Gits/dotnix/scripts/darwin-pre-nix-backup.sh:1) で、~/.config と macOS 固有の設定群、
  Homebrew の Brewfile、/Applications 一覧、pkgutil レシートをまとめて退避できます。[scripts/
  darwin-pre-nix-restore.sh](/Users/inoyu/Gits/dotnix/scripts/darwin-pre-nix-restore.sh:1)
  は、そのバックアップをプレビュー付きで $HOME に戻し、必要なら --restore-brew で Homebrew
  パッケージも再導入します。

  手順と注意点は [docs/darwin-pre-nix-backup.md](/Users/inoyu/Gits/dotnix/docs/darwin-pre-
  nix-backup.md:1) にまとめ、[README.md](/Users/inoyu/Gits/dotnix/README.md:162) にも入口を追
  加しました。バックアップ対象には ~/.config に加えて、AquaSKK、Raycast、iTerm2、Logi、
  Hammerspoon、AltTab、Ice の関連ファイルも含めています。

  検証は bash -n と --help まで実施済みです。実際のバックアップ生成はまだしていません。理由
  は、既定保存先が ~/Backups/... で、ここからその大きなローカルスナップショットを勝手に作るの
  は避けたためです。実行するなら次です。

  chmod +x scripts/darwin-pre-nix-backup.sh scripts/darwin-pre-nix-restore.sh
  ./scripts/darwin-pre-nix-backup.sh

  必要なら次のターンで、そのバックアップ実行までこちらで進めます。

