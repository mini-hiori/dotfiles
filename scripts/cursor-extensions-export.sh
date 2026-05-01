#!/usr/bin/env zsh
# cursor-extensions-export.sh
# 実機にインストール済みの Cursor 拡張機能リストを cursor/extensions.txt に書き出す。
# (install.sh は extensions.txt → 実機方向、本スクリプトは逆方向の同期)
#
# 使い方:
#   cursor-ext-export   # zsh/zshrc.dotfiles.zsh で alias 設定済 (install.sh 実行後)
#   ./scripts/cursor-extensions-export.sh   # 直接実行
#
# 想定ワークフロー:
#   1. Cursor GUI で拡張機能を追加・削除
#   2. 本スクリプトで extensions.txt を更新
#   3. 差分を確認して commit & push → 他マシンの install.sh で同期される

set -euo pipefail

SCRIPT_DIR="${${(%):-%x}:A:h}"
DOTFILES_DIR="${SCRIPT_DIR:h}"
LIST_FILE="$DOTFILES_DIR/cursor/extensions.txt"

if ! command -v cursor >/dev/null 2>&1; then
    echo "cursor CLI が PATH に無い。"
    echo "Cursor で Cmd+Shift+P → 'Shell Command: Install cursor command in PATH' を実行してください。"
    return 1 2>/dev/null || exit 1
fi

mkdir -p "$(dirname "$LIST_FILE")"
cursor --list-extensions > "$LIST_FILE"

count=$(wc -l < "$LIST_FILE" | tr -d ' ')
echo "$LIST_FILE を更新 ($count 件)"
echo "差分を確認して commit してください:"
echo "  git -C $DOTFILES_DIR diff cursor/extensions.txt"
