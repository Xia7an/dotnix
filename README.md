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
│       ├── host.nix          # セットアップスクリプト生成ホストのメタデータ
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
├── lib/
│   └── mk-configurations.nix # NixOS、Darwin、Home の共通生成処理
├── modules/
│   ├── NixOS/                # 再利用可能な NixOS モジュール
│   ├── Home/                 # 再利用可能な Home Manager モジュール
│   ├── darwin/               # 再利用可能な nix-darwin モジュール
│   ├── overlays/             # overlay の定義
│   └── pkgs/                 # ローカルパッケージ
├── config/                   # Home Manager から配置する設定ファイル
├── template/
│   ├── nixos/                # NixOS 用テンプレート
│   ├── nixos-desktop/        # デスクトップ向け NixOS 用テンプレート
│   ├── linux-general/        # Home Manager 用テンプレート
│   └── linux-general-desktop/ # デスクトップ向け Home Manager 用テンプレート
└── scripts/                  # 新規ホストのセットアップスクリプト
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
NixOS / nix-darwin のログインシェルには、対象ユーザーの Home Manager の `programs.fish.package` を使います。システム設定の適用時に切り替わり、macOS の既存ユーザーにも適用されます。fish のパッケージを変更した場合は Home Manager とシステムの両方を適用し、再ログインしてください。

hermes では `home-manager switch --flake .#hermesHome` が、Home Manager のプロファイル内の `bin/fish` を `/etc/shells` に登録し、対象ユーザーのログインシェルを自動設定します。変更が必要な場合のみ sudo 認証を求めます（ホスト OS の `/usr/bin/sudo`・`getent`・`chsh` が必要）。適用後は再ログインしてください。設定済みなら sudo は実行せず、dry-run では変更しません。その他の Home Manager 単独の Linux ホストでは、ログインシェルの登録・変更は OS 側で別途行う必要があります。
Lachesis では GUI アプリを Homebrew cask で管理するため、初回適用前に Homebrew をインストールしてください。システム activation 中に外部スクリプトを取得して Homebrew を自動導入する処理は置いていません。

## Cloudflare WARP

macOS の `Lachesis` は Homebrew cask で WARP を導入します。NixOS では `Anemoi`、`Atropos`、`Nyx` と NixOS テンプレートで WARP デーモンと CLI を有効にしています。`Clotho` は WSL のため対象外です。

Linux ではシステム設定を適用した後、初回のみクライアントを登録して接続します。接続は自動では開始しません。

```bash
warp-cli registration new
warp-cli connect
```

## ChatGPT アプリと Codex CLI

GUI は複数のチャット・プロジェクト、ファイルの確認に、CLI はリポジトリ内の実装・レビュー、SSH、`codex exec` に使う構成です。

| 環境 | ChatGPT GUI | 通常の `codex` |
| --- | --- | --- |
| macOS (`Lachesis`) | 公式アプリを Homebrew cask `chatgpt` で管理 | `llm-agents` の Nix パッケージ |
| Linux デスクトップ (`Anemoi` / `Atropos` / `Nyx`) | 公式 Linux preview を `llm-agents.chatgpt` で管理 | `llm-agents` の Nix パッケージ |
| Home Manager 単独 (`hermes`)・通常版 Linux テンプレート | CLI のみ | `llm-agents` の Nix パッケージ |
| WSL (`Clotho`) | Windows 側で導入 | WSL 内の `llm-agents` の Nix パッケージ |

`modules/Home/apps/ai/codex.nix` は CLI のみ、`chatgpt.nix` は GUI と CLI を導入します。デスクトップ版テンプレートは後者を使います。Linux は x86_64 / ARM64 の両方を上流パッケージがサポートします。

通常の `codex` は両 OS とも `flake.lock` で固定され、Mac の GUI の有無・自己更新から独立します。Herdr 用の `HERDR_AGENT=codex` と上流のシェル補完も維持します。macOS の GUI は公式署名・Keychain 権限と自己更新を保つため Homebrew 管理です。Linux の GUI は NixOS 向けライブラリ設定と、アプリが取得する runtime のパッチを含む上流パッケージを使用します。Linux GUI 自体はプレビュー版で、NixOS は OpenAI の公式サポート対象ディストリビューションには含まれていません。

### 初回利用

Home Manager を適用し、Mac では nix-darwin も適用して GUI を導入します。GUI はアプリ一覧または `chatgpt` で起動できます。

```bash
codex --version
codex login                 # ChatGPT アカウントで CLI にログイン
codex login --device-auth   # SSH など、ローカルでブラウザを開けない場合

# 対象リポジトリ内で
codex
codex resume --last
codex exec "このリポジトリの構成を説明して"
```

GUI でも必要に応じて同じ ChatGPT アカウントにログインします。`~/.codex` の設定・認証・履歴は書き込み可能なままにし、Home Manager から `config.toml` や認証ファイルを上書きしません。モデルはアカウントで利用可能なものをアプリや `/model` から選びます。別の `CODEX_HOME` は設定しません。GUI と CLI の版は異なる場合があるため、特定の機能や会話の再開が両方で同じように動くとは限りません。

Mac で GUI と同じ版の CLI が必要な場合は `codex-bundled` を使えます。Launch Services の識別子 `com.openai.codex` でアプリを取得し、起動のたびに `codex-package.json` の `entrypoint` を解決します。アプリが未導入、メタデータが未知、起動先が複数の場合は診断を出して停止します。

Linux では Wayland セッションを上流ラッパーが扱います。ネイティブ Wayland はまだ実験的なので、表示やフォーカスに問題がある場合は XWayland が使える環境で `chatgpt --ozone-platform=x11`、ネイティブ Wayland を選ぶ場合は `chatgpt --ozone-platform=wayland` を使います。GUI の動作にはデスクトップセッションが必要です。

### 更新

```bash
nix flake update llm-agents
home-manager switch --flake .#LachesisHome # Linux は対象の <Host>Home に変更
brew upgrade --cask chatgpt               # macOS の GUI
```

Nix 管理の CLI と Linux GUI は Nix 入力の更新・再適用で更新します。macOS の GUI はアプリ自身または Homebrew で更新します。

参考: [Codex CLI](https://developers.openai.com/codex/cli/)、[Linux アプリ](https://developers.openai.com/codex/linux/linux-app/)、[llm-agents.nix](https://github.com/numtide/llm-agents.nix)。

## 新しい Linux ホストのセットアップ

スクリプトはリポジトリ内のどこからでも実行できます。ホスト名を省略すると対話入力になります。生成された `hosts/<Host>/host.nix` は `hosts/default.nix` によって自動検出されるため、ホスト一覧を手作業で編集する必要はありません。`x86_64-linux` と `aarch64-linux` を実行環境から自動判定します。Linux ARM64用の固定情報をまだ持っていないPlatformIO IDE拡張だけは、`aarch64-linux` で除外します。

NixOS では `/etc/nixos/hardware-configuration.nix` を `hardware.nix` としてコピーした後、`nixos-rebuild switch` と `home-manager switch` を順に実行します。

```bash
./scripts/setup-nixos.sh
# または: ./scripts/setup-nixos.sh MyHost
# デスクトップ向け: ./scripts/setup-nixos.sh --desktop MyHost
```

NixOS テンプレートのブートローダー設定は Nyx と同じ `/dev/sda` 向けです。構成が異なるホストでは、初回の rebuild を実行する前に使用する `template/nixos*/system.nix` を変更してください。

一般的な Linux では、Nix がなければ公式インストーラーの single-user モードで導入し、Home Manager を適用します。

```bash
./scripts/setup-linux-general.sh
# または: ./scripts/setup-linux-general.sh MyHost
# デスクトップ向け: ./scripts/setup-linux-general.sh --desktop MyHost
```

`--desktop` を付けると、それぞれ `nixos-desktop`、`linux-general-desktop` テンプレートを使用します。通常版は Codex CLI のみ、デスクトップ版は ChatGPT GUI も導入します。そのほかのアプリケーション構成もテンプレートごとに変更できます。

既に Nix を利用できる場合、一般 Linux 用スクリプトは管理者権限を使いません。Nix 未導入かつ `/nix` が存在しない場合だけ、公式インストーラーが `/nix` の作成のために管理者権限を求めることがあります。通常ユーザーとしてスクリプトを実行してください。

セットアップ時には `~/.config/nix/nix.conf` へ `nix-command` と `flakes` を有効にする設定を追加し、初回実行でも各Nixコマンドへ同じ機能を明示します。rebuildやHome Manager適用の途中で失敗した場合は、同じホスト名でスクリプトを再実行すると生成済みのホスト構成を再利用して処理を続行します。

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
