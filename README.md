# dotnix

NixOS、NixOS-WSL、nix-darwin、Home Manager の設定を 1 つの flake で管理するリポジトリです。依存関係は `flake.lock` に固定し、ホスト定義から各出力を生成します。

## 対象ホスト

| ホスト | 種別 | アーキテクチャ | Home Manager 出力 |
| --- | --- | --- | --- |
| `Anemoi` | NixOS | `x86_64-linux` | `AnemoiHome` |
| `Atropos` | NixOS | `x86_64-linux` | `AtroposHome` |
| `Clotho` | NixOS-WSL | `x86_64-linux` | `ClothoHome` |
| `Nyx` | NixOS | `x86_64-linux` | `NyxHome` |
| `Lachesis` | nix-darwin | `aarch64-darwin` | `LachesisHome` |

ホストのメタデータは `hosts/default.nix` が唯一の定義元です。新しいホストを追加するときは、ここへシステムと Home Manager のエントリーポイントを登録します。

## ディレクトリ構成

```text
.
├── flake.nix                 # 公開する outputs の薄いエントリーポイント
├── flake.lock                # 入力の固定バージョン
├── hosts/
│   ├── default.nix           # ホスト一覧とプラットフォーム情報
│   └── <Host>/
│       ├── system.nix        # NixOS / nix-darwin のホスト固有設定
│       ├── home.nix          # Home Manager のエントリーポイント
│       └── home-manager/     # 用途別の Home Manager 設定
│           ├── applications.nix
│           ├── desktop-environment.nix
│           ├── development-tools.nix
│           ├── editors.nix
│           ├── shell-and-command-line.nix
│           ├── terminal-emulators.nix
│           └── virtualization.nix
├── hardware/                 # ハードウェア固有設定
├── lib/
│   └── mk-configurations.nix # NixOS、Darwin、Home の共通生成処理
├── modules/
│   ├── NixOS/                # 再利用可能な NixOS モジュール
│   ├── Home/                 # 再利用可能な Home Manager モジュール
│   ├── darwin/               # 再利用可能な nix-darwin モジュール
│   ├── overlays/             # overlay の定義
│   └── pkgs/                 # ローカルパッケージ
└── config/                   # Home Manager から配置する設定ファイル
```

`home-manager/` 配下は、そのホストで有効にする機能をファイル名どおりに分類しています。ホストによって不要なカテゴリは空の `imports` として残してあり、あとから設定を追加するときの変更先を判断しやすくしています。macOS ホストには、このほか `macos-integration.nix` があります。

`system.stateVersion` と `home.stateVersion` は互換性の基準です。入力を更新しただけでは変更せず、各プロジェクトのリリースノートを確認したうえで明示的に移行します。

## パッケージのチャンネル

既定はすべて安定版 (`nixpkgs-25.11`) です。`pkgs.<name>` は常に安定版を指します。

unstable 版が必要なパッケージは、**呼び出し側で `pkgs.unstable.<name>` と明示的に書きます**。

```nix
{ pkgs, ... }:
{
  # 安定版
  home.packages = [ pkgs.ripgrep ];

  # unstable 版 (更新が速く、安定版では古すぎるもの)
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
  };
}
```

Home Manager の `programs.*` モジュールは既定で安定版を使うため、unstable 版にしたい場合は `package` を明示してください。`pkgs.unstable` は NixOS / nix-darwin モジュールからも同じように参照できます。

overlay の定義は `modules/overlays/` にあります。

| ファイル | 役割 |
| --- | --- |
| `default.nix` | system ごとの overlay リストを組み立てる |
| `local-packages.nix` | `modules/pkgs/` の自作パッケージを追加する (`overlays.default` として外部公開) |
| `unstable.nix` | nixpkgs-unstable 一式を `pkgs.unstable` として追加する |

## 適用

リポジトリのルートで、対象ホスト名を指定します。

```bash
# NixOS
sudo nixos-rebuild switch --flake .#Atropos

# Home Manager（全プラットフォーム共通）
home-manager switch --flake .#AtroposHome

# nix-darwin
sudo darwin-rebuild switch --flake .#Lachesis
```

Home Manager はシステムと独立して適用できる構成を維持しています。
Lachesis では GUI アプリを Homebrew cask で管理するため、初回適用前に Homebrew をインストールしてください。システム activation 中に外部スクリプトを取得して Homebrew を自動導入する処理は置いていません。

## 検証と整形

変更を適用する前に、flake 全体を評価します。

```bash
nix flake check
nix fmt
```

個別に評価だけを確認する場合:

```bash
nix build .#nixosConfigurations.Atropos.config.system.build.toplevel --dry-run
nix build .#homeConfigurations.AtroposHome.activationPackage --dry-run
```

ローカルパッケージ `niri-taskbar` は次の出力でも公開しています。

```bash
nix build .#niri-taskbar
```

## 更新

依存関係は一括更新よりも入力単位で更新し、更新後に必ず評価します。

```bash
nix flake update nixpkgs home-manager
nix flake check
```

安定版 `nixpkgs`、Home Manager、nix-darwin は同じリリース系列に揃えます。

## 参考資料

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix reference manual](https://nix.dev/manual/nix/latest/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin](https://github.com/nix-darwin/nix-darwin)
