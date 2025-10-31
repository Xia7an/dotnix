# dotnix - NixOS & Home Manager 設定

このリポジトリは NixOS と Home Manager を使った再現性のあるシステム構成です。

## 概要

- **OS**: NixOS
- **パッケージマネージャー**: Nix Flakes
- **ユーザー環境管理**: Home Manager
- **対象ホスト**: Atropos, Nyx

## 構成

### NixOS 設定

- `Atropos.nix`: Atropos ホストの NixOS 設定
- `Nyx.nix`: Nyx ホストの NixOS 設定
- `flake.nix`: Flakes 設定ファイル
- `hardware/`: ハードウェア固有の設定

### Home Manager 設定

- `home.nix`: ユーザー環境の統合設定
- `module/Home/`: ユーザー環境のモジュール群
- `config/`: アプリケーション設定ファイル（シンボリックリンク元）

## 主要機能

### デスクトップ環境

- **WM**: Niri（Wayland コンポジター）
- **Bar**: Waybar
- **ランチャー**: Wofi
- **IME**: Fcitx5 + Mozc（日本語入力）
- **VPN**: Tailscale
- **通知**: nm-applet

### アプリケーション

- **メール**: Thunderbird
- **チャット**: Discord
- **ドキュメントビューワ**: Okular
- **ファイルマネージャー**: Nautilus + GNOME Sushi
- **ノート**: Notion, Obsidian

### ターミナル環境

- **エミュレータ**: Alacritty
- **シェル**: fish + Starship
- **エディタ**: Neovim (Lazyvim ベース)
- **ファイラー**: yazi

### 開発ツール

- **コンパイラ**: gcc, g++
- **環境マネージャー**: mise (node, cargo 管理)
- **Python**: uv
- **IDE**: Unity Hub, JetBrains Rider, VSCode
- **AI**: GitHub Copilot (VSCode 拡張 + CLI)

## ビルド手順

### NixOS のビルド

```fish
# Atropos ホストの場合
sudo nixos-rebuild switch --flake .#Atropos

# Nyx ホストの場合
sudo nixos-rebuild switch --flake .#Nyx
```

### Home Manager のビルド

```fish
# Atropos ホストの場合
home-manager switch --flake .#AtroposHome

# Nyx ホストの場合
home-manager switch --flake .#NyxHome
```

## モジュール構造

### Home Manager モジュール (`module/Home/`)

モジュールはカテゴリーごとに整理されています：

- **`terminal/`**: ターミナル関連
  - `alacritty.nix`: Alacritty 設定
  - `kitty.nix`: Kitty 設定
  - `fish.nix`: fish シェル + Starship
  - `zsh.nix`: zsh シェル
  
- **`editor/`**: エディタ関連
  - `neovim.nix`: Neovim + Lazyvim 設定
  - `vscode.nix`: VSCode + 拡張機能
  
- **`desktop/`**: デスクトップ環境
  - `niri.nix`: Niri コンポジター
  - `hyprland.nix`: Hyprland
  - `sway.nix`: Sway
  - `waybar.nix`: Waybar（ステータスバー）
  - `wofi.nix`: Wofi（ランチャー）
  - `wlogout.nix`, `anyrun.nix`, `walker.nix`
  
- **`apps/`**: アプリケーション
  - `chrome.nix`, `vivaldi.nix`: ブラウザ
  - `discord.nix`: Discord
  - `steam.nix`: Steam
  
- **`development/`**: 開発環境
  - `general.nix`: 一般的な開発ツール
  - `git.nix`: Git 設定
  - `direnv.nix`: direnv
  - `rust.nix`: Rust 環境
  - `dev-tools.nix`: CLI 開発ツール（yazi, gcc, mise, uv）
  - `dev-apps.nix`: GUI 開発アプリ（Unity Hub, Rider）
  
- **`input/`**: 入力メソッド
  - `fcitx5.nix`: Fcitx5 + Mozc
  - `ibus.nix`: IBus（代替）

### NixOS モジュール (`module/NixOS/`)

- **`desktop/`**: デスクトップ環境関連
  - `default.nix`: デスクトップモジュールの統合
  - `niri.nix`: Niri システム設定
  - `apps.nix`: デスクトップアプリケーション
  - `nautilus.nix`, `thunderbird.nix`, `kdeconnect.nix` など
  
- **`develop/`**: 開発環境設定
  - Python, Unity などの開発ツール
  
- **`system/`**: システムレベルのサービス
  - `utils.nix`: ユーティリティツール
  - `docker.nix`: Docker
  - `qemu.nix`: QEMU 仮想化
  - `sunshine.nix`: Sunshine リモートデスクトップ
  - `parsec.nix`: Parsec
  - `ollama.nix`: Ollama（LLM）
  - `gemini.nix`: Gemini
  - `stock-ticker.nix`: 株価ティッカー
  - `wine.nix`: Wine
  
- **`apps/`**: アプリケーション
  - `discord.nix`: Discord
  - `blender.nix`: Blender
  - `dolphin.nix`: Dolphin
  - `gaming.nix`: ゲーム関連
  
- **`input/`**: 入力メソッド
  - `fcitx5.nix`: Fcitx5 システム設定
  - `ibus.nix`: IBus（代替）
  
- **`windows/`**: Windows 互換レイヤー（Wine, Bottles）

## 設定ファイル (`config/`)

各アプリケーションの設定ファイルは `config/` ディレクトリに保存され、Home Manager によってシンボリックリンクで配置されます。

- `config/niri/config.kdl`: Niri 設定
- `config/alacritty/alacritty.toml`: Alacritty 設定
- `config/waybar/`: Waybar 設定
- `config/wofi/`: Wofi 設定
- `config/nvim/`: Neovim 設定

**注意**: `config/` ディレクトリの内容は直接変更してください。Nix 設定からは参照のみ行います。

## よくある操作

### 新しいパッケージを追加

1. システムパッケージ: `Atropos.nix` または `Nyx.nix` の `environment.systemPackages` に追加
2. ユーザーパッケージ: 適切なモジュール（例: `dev-tools.nix`）の `home.packages` に追加

### 設定ファイルを変更

1. `config/` ディレクトリ内のファイルを直接編集
2. Home Manager をリビルド（変更は即座に反映されます）

### ディスクをマウント

詳細は `docs/disk-mount.md` を参照してください。

## フォント設定

日本語フォントは以下が設定済みです：

- **Serif**: Noto Serif CJK JP
- **Sans-Serif**: Noto Sans CJK JP
- **Monospace**: JetBrainsMono Nerd Font (HackGen も利用可能)
- **Emoji**: Noto Color Emoji

## トラブルシューティング

### ビルドエラーが発生した場合

```fish
# Flake のロックファイルを更新
nix flake update

# キャッシュをクリア
sudo nix-collect-garbage -d
```

### Home Manager の設定が反映されない

```fish
# Home Manager のステートをリセット
home-manager expire-generations "-30 days"

# 再ビルド
home-manager switch --flake .#AtroposHome
```

## ライセンス

このリポジトリの設定ファイルは個人用途です。含まれるソフトウェアは各ライセンスに従います。

## 参考リンク

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
