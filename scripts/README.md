# scripts

dotfiles 内の業務補助 shell スクリプト群。リポジトリ root で [`install.sh`](../install.sh) を実行すると、`scripts/` への `PATH` 通しと各スクリプトの推奨エイリアス設定 ([`zsh/zshrc.dotfiles.zsh`](../zsh/zshrc.dotfiles.zsh) 経由) が自動で行われる。

## aws-sso-login.sh

AWS SSO で利用するアカウントを番号選択 → 対応する AWS CLI プロファイルを自動作成 (なければ) → `aws sso login` 実行 → `AWS_PROFILE` をシェルに export までを一括で行う。

### エイリアス

`zsh/zshrc.dotfiles.zsh` で自動設定される (`install.sh` 実行後に有効):

```sh
alias awssso='source aws-sso-login.sh'
```

`source` で呼ぶ理由は、スクリプト内の `export AWS_PROFILE` を呼び出し元シェルに反映させるため。

### 初回セットアップ

機微情報 (アカウント一覧・SSO Start URL) を保持する `aws-sso-config.local.sh` (`.gitignore` 対象) は `install.sh` がテンプレートからコピー済み。自分の環境に合わせて編集する:

```sh
$EDITOR scripts/aws-sso-config.local.sh
```

`ACCOUNTS` 配列にログイン対象アカウントを `ACCOUNT_ID:ROLE_NAME:ENV_NAME:DESCRIPTION` の形式で列挙し、`SSO_START_URL` に IAM Identity Center の Start URL を設定する。

### 使い方

```sh
awssso
```

番号でアカウントを選ぶと、対応する AWS CLI プロファイルが (なければ) 作成され、SSO ログイン後に `AWS_PROFILE` が現在のシェルに export される。

## cursor-extensions-export.sh

実機にインストール済みの Cursor 拡張機能リストを `cursor/extensions.txt` に書き出す。`install.sh` は逆方向 (extensions.txt → 実機) のため、本スクリプトは **GUI で追加・削除した分を dotfiles 側に反映** するためのもの。

### エイリアス

`zsh/zshrc.dotfiles.zsh` で自動設定:

```sh
alias cursor-ext-export='cursor-extensions-export.sh'
```

### 想定ワークフロー

1. Cursor GUI で拡張機能を追加・削除
2. `cursor-ext-export` を実行 → `cursor/extensions.txt` が更新される
3. `git diff cursor/extensions.txt` で内容確認 → commit & push
4. 別マシンの `install.sh` 実行で同期される

### 前提

`cursor` CLI が PATH に通っていること。Cursor で `Cmd + Shift + P` → `Shell Command: Install 'cursor' command in PATH` を実行して導入する。
