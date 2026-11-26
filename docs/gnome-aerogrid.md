# GNOME AeroGrid (Odin)

Lachesis の AeroSpace (floating 運用) + Hammerspoon の Option+Tab グリッドを、
Ubuntu 24.04 標準の GNOME 46 (Mutter / X11) で再現する。キーボードは Magic Keyboard。

| macOS (Lachesis) | GNOME (Odin) |
| --- | --- |
| AeroSpace の floating | GNOME 標準 (もともと floating) |
| 32 個の名前付きワークスペース (モニタごとに別表示) | AeroGrid の仮想ワークスペース |
| `on-window-detected` | AeroGrid の `RULES` (WM_CLASS で判定) |
| Option+文字 (`summon-workspace`) | 同じ。操作中のモニタに呼ぶ |
| Option+Shift+文字 (`move-node-to-workspace`) | 同じ。移動したウィンドウには追従しない |
| (メニューバーのワークスペース表示) | 上部バーのワークスペース表示 |
| Option+Tab (Hammerspoon グリッド) | AeroGrid のグリッド |
| Command+Tab (alt-tab-macos) | GNOME の `switch-windows` (全ワークスペース) |
| Raycast の Window Management | Option+Control+hjkl/Space (AeroGrid) |
| Dock 自動非表示 | Ubuntu Dock を下・自動非表示 |

Magic Keyboard は Linux の `hid_apple` で Option = Alt、Command = Super になる。
そのため AeroGrid は Alt を、GNOME のウィンドウスイッチャーは Super を使う。

## 仮想ワークスペース

AeroSpace が macOS の Spaces を使わないのと同じく、GNOME (Mutter) のワークスペースは
1 つにまとめ、32 個のワークスペースは AeroGrid が管理する。

- 各モニタはワークスペースを 1 つずつ表示する。表示していないワークスペースの
  ウィンドウは、アニメーションなしで最小化して隠す。
- Option+文字は、そのワークスペースを操作中のモニタ (フォーカス中のウィンドウのモニタ。
  空のワークスペースでは最後に操作したモニタ) に表示し、最後に使ったウィンドウにフォーカスする。
  別のモニタに表示中だった場合は、2 つのモニタの表示を入れ替える。
- 新しいウィンドウは、規則があればそのワークスペース、無ければ操作中のモニタの
  ワークスペースに入る。表示されていないワークスペースなら開いた時点で隠す。
- ウィンドウをドラッグなどで別のモニタへ移すと、移動先のモニタのワークスペースに所属が変わる。
- Dock、Command+Tab、通知などから隠れたウィンドウを開くと、そのワークスペースを
  ウィンドウがあるモニタに表示する。
- 自分で最小化したウィンドウは、ワークスペースを表示しても最小化されたまま。
- モニタを外すと、そのモニタのワークスペースは隠れる。つなぐと、空きのワークスペースを表示する。
- 所属と表示状態は `~/.cache/aerogrid/state.json` に保存し、GNOME Shell の再起動後に
  X11 のウィンドウ ID で復元する。初回は GNOME のワークスペースの所属を引き継ぐ。
- 拡張を無効にすると、隠していたウィンドウをすべて表示に戻す。画面ロック中は無効にならない。

### 上部バーの表示

アクティビティの右に、ウィンドウがあるワークスペースと表示中のワークスペースを並べる。

| 見た目 | 意味 |
| --- | --- |
| 青の塗りつぶし | 操作中のモニタに表示中 (今いるワークスペース) |
| 青の枠 | 別のモニタに表示中 |
| 薄い文字 | 隠れているがウィンドウがある |

クリックすると、そのワークスペースを操作中のモニタに呼ぶ。

## グリッドの操作

Hammerspoon 版 (`docs/aerospace-window-grid.md`) と同じ。

| 操作 | 動作 |
| --- | --- |
| Option + Tab | 一覧を開く。初期選択は現在のウィンドウ |
| h / l、左右キー | 同じワークスペース内の前後のウィンドウ |
| j / k、上下キー | 下 / 上のワークスペース |
| Option を離す | 選択したウィンドウにフォーカス。隠れていれば操作中のモニタにそのワークスペースを呼ぶ |
| Esc、一覧の外をクリック | 何も変えずに閉じる |

最大 4 列 × 6 行。行ごとに選択と横スクロールを保持し、選択に 1 項目ずつ追従する。
プレビューは `Clutter.Clone` で描き、画像を保持しない。隠れているウィンドウは
最後に描画された内容を表示する。
文字の高さは開くたびに実際のラベルで測り、表示倍率 (HiDPI) や「大きな文字」の
設定に合わせて枠を広げる。長いタイトルは 1 行に収めて末尾を省略する。

## ウィンドウ配置

Raycast と同じキーで、フォーカス中のウィンドウをそのモニタの作業領域 (パネルと Dock を除く範囲) に合わせる。

| 操作 | 動作 |
| --- | --- |
| Option + Control + H / L | 左半分 / 右半分 |
| Option + Control + K / J | 上半分 / 下半分 |
| Option + Control + Space | 作業領域いっぱい (GNOME の最大化状態にはしない) |

最大化・全画面のウィンドウは解除してから配置する。キーと配置は `config.js` の
`PLACEMENT_KEYS` で変えられる。画面ロックは Command+L (Super+L) のみにして、
Ctrl+Alt+L を空けている。

## 構成

- `config/gnome-shell/aerogrid/`: 拡張本体 (UUID `aerogrid@inoyu`)
  - `config.js`: 修飾キー、ワークスペース一覧、アプリの割り当てルール、配置のキー
  - `extension.js`: 仮想ワークスペース、キー登録、割り当て、状態の保存
  - `grid.js`: グリッドの UI
  - `indicator.js`: 上部バーのワークスペース表示
  - `workspaces.js`: モニタごとの表示状態 (GNOME 非依存、テスト対象)
  - `model.js`: グリッドの状態とレイアウト (GNOME 非依存、テスト対象)
  - `placement.js`: ウィンドウ配置の計算 (GNOME 非依存、テスト対象)
- `modules/Home/desktop/gnome/`: Home Manager モジュール
  - `workspaces.nix`: GNOME のワークスペースを 1 つに固定
  - `keybindings.nix`: GNOME の Alt+Tab / Alt+` を外し、Command 側へ移す
  - `dock.nix`: Ubuntu Dock
  - `aerogrid.nix`: 拡張を `~/.local/share/gnome-shell/extensions/` へリンクして有効化
- `hosts/Odin/`: `template/linux-general-desktop` を元にしたホスト

## 適用

```sh
home-manager switch --flake .#OdinHome
```

初回はその後ログアウトして再ログインする (GNOME Shell が新しい拡張を読むため)。
`enabled-extensions` は Home Manager が丸ごと置き換える。Ubuntu Dock などの標準拡張は
セッションモード側で有効になるので影響しないが、手動で入れた拡張は `aerogrid.nix` に追加する。

拡張はリポジトリ (`~/Gits/dotnix`) へ直接リンクしている。`config.js` などを編集したら
switch は不要で、`Alt+F2` → `r` → Enter で GNOME Shell を再起動すれば反映される (X11 のみ)。

## ルールの追加

`xprop WM_CLASS` を実行してウィンドウをクリックすると `WM_CLASS = "instance", "Class"` が出る。
どちらかに一致する正規表現を `config.js` の `RULES` に足す。割り当ては新しく開いた
ウィンドウだけに適用し、既存のウィンドウは動かさない。

## トラブルシュート

```sh
journalctl -f -o cat /usr/bin/gnome-shell   # 拡張のログとエラー
gnome-extensions info aerogrid@inoyu         # 状態 (ACTIVE / ERROR)
gsettings list-recursively | grep -E "<Alt>[a-z0-9]'|<Alt>Tab"   # キーの衝突確認
```

`AeroGrid: <Alt>... を登録できません` と出たら、同じキーを GNOME や別のアプリが使っている。

## テスト

```sh
node tests/gnome-aerogrid-model-test.mjs
node tests/gnome-aerogrid-workspaces-test.mjs
```

並び順、初期選択、端での停止、行ごとの横スクロールと位置の復元、6 行を超える縦スクロール、
画面内への収まり、表示倍率 2 倍や大きな文字でも文字が枠に収まって重ならないこと、
ウィンドウ配置の矩形、モニタごとの表示状態 (復元、summon と入れ替え、モニタの抜き差し、
上部バーの項目) を確認する。実機では、複数ワークスペースにウィンドウを置いて Option+Tab を押し、
hjkl で枠だけが動くこと、Option を離すと別のワークスペースのウィンドウに移れることを確認する。

## 制限

- 隠れたウィンドウは最小化として扱われるため、Dock では最小化中のアプリに見え、
  アクティビティ画面には表示中のワークスペースのウィンドウしか出ない。探すときは Option+Tab を使う。
- 最小化できないウィンドウ (一部のダイアログなど) は隠せず、表示したままになる。
- `move-workspace-to-monitor` (Option+Shift+Tab) は未実装。Option+文字で呼べば同じ結果になる。
- モニタ番号はつなぎ直すと入れ替わることがある。その場合、表示中のワークスペースもモニタ間で入れ替わる。
- L (Looking Glass Go) のモニタ固定は未対応。割り当てだけ行う。
- 対象は GNOME 46。GNOME 49 以降 (Ubuntu 26.04 など) では `metadata.json` の
  `shell-version` の追加と API の確認が必要。X11 セッションが無くなるため、
  `Alt+F2 r` による再読込も使えなくなる。
