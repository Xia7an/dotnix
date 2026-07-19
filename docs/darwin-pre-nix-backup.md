# macOS 移行前バックアップ

`Lachesis` を Nix / Home Manager 管理へ切り替える前に、移行前状態へ戻すための退避ポイントを作る手順です。

## 目的

- Homebrew のインストール状態を記録する
- `~/.config` と macOS 固有設定ファイルを退避する
- 失敗時に Nix 管理前の状態へ戻すための復元スクリプトを残す

## 作成されるもの

バックアップスクリプトはデフォルトで以下へ退避します。

```text
~/Backups/dotnix-pre-nix/<LocalHostName>-pre-nix-<timestamp>
```

主な内容:

- `archives/home-state.tar.gz`
  - `~/.config`
  - `~/.hammerspoon`
  - `~/.aerospace.toml`
  - `~/Library/Application Support/AquaSKK`
  - `~/Library/Application Support/com.raycast.macos`
  - `~/Library/Application Support/iTerm2`
  - `~/Library/Application Support/Logi`
  - 関連 plist
- `inventory/brew/Brewfile`
  - Homebrew formula / cask / tap / `mas` 情報
- `inventory/apps/`
  - `/Applications` と `~/Applications` の `.app` 一覧
- `inventory/system/`
  - `pkgutil` レシート一覧
  - `sw_vers`
  - `dotnix` リポジトリ状態
- `scripts/darwin-pre-nix-restore.sh`
  - バックアップ時点の復元スクリプト

## 実行

```bash
chmod +x scripts/darwin-pre-nix-backup.sh scripts/darwin-pre-nix-restore.sh
./scripts/darwin-pre-nix-backup.sh
```

保存先を明示したい場合:

```bash
./scripts/darwin-pre-nix-backup.sh "$HOME/Backups/dotnix-pre-nix/manual-pre-switch"
```

## 復元

まずはプレビュー:

```bash
~/Backups/dotnix-pre-nix/<backup>/scripts/darwin-pre-nix-restore.sh \
  ~/Backups/dotnix-pre-nix/<backup>
```

実際にファイルを戻す:

```bash
~/Backups/dotnix-pre-nix/<backup>/scripts/darwin-pre-nix-restore.sh \
  --yes \
  ~/Backups/dotnix-pre-nix/<backup>
```

Homebrew パッケージも戻す:

```bash
~/Backups/dotnix-pre-nix/<backup>/scripts/darwin-pre-nix-restore.sh \
  --yes \
  --restore-brew \
  ~/Backups/dotnix-pre-nix/<backup>
```

## 注意

- 復元スクリプトは `$HOME` 直下へ上書きするため、必ずプレビューしてから実行してください。
- Homebrew 復元は `Brewfile` ベースの best-effort です。非 Homebrew 配布アプリは `inventory/apps/` を見ながら手動再導入が必要です。
- Raycast などのアプリ状態はローカルバックアップとしては戻せますが、認証状態や OS 権限は別途再許可が必要になる場合があります。
