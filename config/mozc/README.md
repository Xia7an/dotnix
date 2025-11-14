# IBus-Mozc のキー設定

このディレクトリには IBus-Mozc のキーマップ設定が含まれています。

## keymap.txt

Mozc のカスタムキーマップ設定ファイルです。

### 設定内容

- **変換キー（Henkan）**: IME を有効化
- **無変換キー（Muhenkan）**: IME を無効化
- **全角/半角キー**: IME のオン/オフ切り替え（デフォルト動作）

### 使い方

この設定は Home Manager により自動的に `~/.config/mozc/keymap.txt` に配置されます。

### カスタマイズ

`config/mozc/keymap.txt` を編集して、独自のキーバインドを追加できます。

フォーマット: `status	key	command`

#### 利用可能な status
- `DirectInput`: 直接入力モード
- `Precomposition`: 入力前状態
- `Composition`: 変換前入力中
- `Conversion`: 変換候補選択中

#### よく使うコマンド
- `IMEOn`: IME を有効化
- `IMEOff`: IME を無効化
- `Commit`: 確定
- `Cancel`: キャンセル

#### キー名の例
- `Henkan`: 変換キー
- `Muhenkan`: 無変換キー
- `Hankaku/Zenkaku`: 全角/半角キー
- `Ctrl Space`: Ctrl + Space
- `Shift Space`: Shift + Space

### 適用方法

1. `config/mozc/keymap.txt` を編集
2. Home Manager を再ビルド: `home-manager switch --flake .#AtroposHome`
3. IBus を再起動: `ibus restart`

### トラブルシューティング

設定が反映されない場合:

```fish
# IBus を再起動
ibus restart

# Mozc の設定ツールで確認
ibus-setup

# キーマップファイルの配置を確認
ls -la ~/.config/mozc/keymap.txt
```
