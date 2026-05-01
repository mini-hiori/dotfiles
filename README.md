# dotfiles

個人の開発環境設定一式。

## 含まれる設定

| ツール | パス |
|--------|------|
| [Ghostty](https://ghostty.org/) | [`ghostty/config`](./ghostty/config) |
| [Cursor](https://www.cursor.com/) | [`cursor/`](./cursor) (`settings.json`, `keybindings.json`) |
| 業務改善スクリプト | [`scripts/`](./scripts) (`aws-sso-login.sh` ほか) |
| zsh 設定スニペット (PATH / エイリアス) | [`zsh/zshrc.dotfiles.zsh`](./zsh/zshrc.dotfiles.zsh) |

## インストール (macOS)

リポジトリ root で `install.sh` を実行する:

```sh
./install.sh
```

実行内容:

- Ghostty / Cursor の設定ファイルを `~/Library/Application Support/...` 配下に **symlink で配置**
- `~/.zshrc` の末尾に `source "<dotfiles>/zsh/zshrc.dotfiles.zsh"` を **1 行追記** (既存 zshrc を破壊しない追記型。重複検出済み)
- `scripts/aws-sso-config.local.sh` を `.example` から **テンプレートコピー** (要編集、後述)

**衝突時の挙動**: 既存ファイルは `<target>.bak.YYYYMMDDHHMMSS` 形式でバックアップしてから置き換える。

完了後、新しいシェルを起動するか `source ~/.zshrc` で反映。設定変更後の Ghostty は `Cmd + Shift + ,` でリロード可能。

### AWS SSO 設定の編集 (初回のみ)

`install.sh` 実行後、機微情報 (アカウント一覧・SSO Start URL) を入力する:

```sh
$EDITOR scripts/aws-sso-config.local.sh
```

`aws-sso-config.local.sh` は `.gitignore` 対象のため commit されない。

## scripts/ の使い方

`scripts/` 配下は日々の業務を補助する shell スクリプトの置き場。`install.sh` が `~/.zshrc` に [`zsh/zshrc.dotfiles.zsh`](./zsh/zshrc.dotfiles.zsh) を source するよう設定するため、シェル起動時に以下が自動で有効になる:

- `scripts/` が `$PATH` に追加される (重複追加防止ガード付き)
- 各スクリプトの推奨エイリアス (例: `awssso` → `source aws-sso-login.sh`)

各スクリプトの用途・初回セットアップは [`scripts/README.md`](./scripts/README.md) を参照。

## ツール別の概要

### Ghostty

- **フォント**: HackGen35 Console NF
- **テーマ**: Monokai Pro
- **背景**: 不透明度 0.9 + ブラー 20px
- **カーソル**: bar スタイル + blink
- **シェル統合**: 自動検出 (作業ディレクトリ引き継ぎ等)
- **キーバインド**: `Ctrl + A` / `Ctrl + E` を Emacs 風カーソル移動の legacy escape (`\x01` / `\x05`) で送出 — CSI u 非対応アプリ向けの互換キー

全設定項目の確認:

```sh
ghostty +show-config --default --docs
```

### Cursor

- **テーマ**: One Monokai (`workbench.colorTheme`)
- **アイコンテーマ**: material-icon-theme
- **アクティビティバー**: 縦置き (`workbench.activityBar.orientation: vertical`)
- **コマンドセンター**: 有効 (`window.commandCenter`)
- **ファイル末尾**: 改行を自動挿入 (`files.insertFinalNewline`)
- **拡張機能の推薦**: 抑止 (`extensions.ignoreRecommendations`)
- **Claude Code 拡張**: edit 確認をスキップ、UI は Panel 配置
- **Git**: 親フォルダのリポジトリは自動オープンしない
- **キーバインド**:
  - `Cmd + I` → Composer の Agent モード起動
  - `Shift + Enter` (ターミナル focus 時) → `\<改行>` を送出して shell で複数行入力を継続

> **note**: `install.sh` が配置する symlink 経由のため、Cursor の GUI で設定変更すると symlink を辿ってリポジトリ側の `cursor/settings.json` / `cursor/keybindings.json` が直接書き換わる。手元で変更したい場合は通常通り設定 UI から触ってよい (リポジトリ側に反映されるので、その後 commit する運用)。
