#!/usr/bin/env bash
# install.sh - dotfiles のセットアップ
#
# 各ツールの設定ファイルを ~/Library/Application Support/ 等に symlink で配置し、
# ~/.zshrc に dotfiles 由来の zshrc.dotfiles.zsh を source する 1 行を追記する。
# 既存ファイルがある場合は <target>.bak.YYYYMMDDHHMMSS 形式でバックアップしてから置き換える。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

log()     { printf '  %s\n' "$*"; }
section() { printf '\n=== %s ===\n' "$*"; }

backup_existing() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}.bak.${TIMESTAMP}"
    log "既存をバックアップ: ${target} → ${backup}"
    mv "$target" "$backup"
  fi
}

ensure_symlink() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log "既に symlink 済み (skip): $target"
      return 0
    fi
  fi

  backup_existing "$target"
  ln -snf "$source" "$target"
  log "symlink 作成: $target → $source"
}

ensure_zshrc_source_line() {
  local zshrc="$HOME/.zshrc"
  local source_line='source "'"$SCRIPT_DIR"'/zsh/zshrc.dotfiles.zsh"'

  if [[ -f "$zshrc" ]] && grep -Fxq "$source_line" "$zshrc"; then
    log "既に source 行あり (skip): $zshrc"
    return 0
  fi

  if [[ -f "$zshrc" ]]; then
    cp -p "$zshrc" "${zshrc}.bak.${TIMESTAMP}"
    log "~/.zshrc をバックアップ: ${zshrc}.bak.${TIMESTAMP}"
  fi

  {
    printf '\n# dotfiles\n'
    printf '%s\n' "$source_line"
  } >> "$zshrc"
  log "source 行を追記: $zshrc"
}

ensure_cursor_extensions() {
  local list_file="$SCRIPT_DIR/cursor/extensions.txt"

  if [[ ! -f "$list_file" ]]; then
    log "extensions.txt が無いため skip: $list_file"
    return 0
  fi

  if ! command -v cursor >/dev/null 2>&1; then
    log "cursor CLI が PATH に無いため skip"
    log "Cursor で Cmd+Shift+P → 'Shell Command: Install cursor command in PATH' を実行後に install.sh 再実行で適用される"
    return 0
  fi

  local installed
  installed="$(cursor --list-extensions 2>/dev/null || true)"

  local total=0 newly=0
  while IFS= read -r ext || [[ -n "$ext" ]]; do
    [[ -z "$ext" || "$ext" == "#"* ]] && continue
    total=$((total + 1))
    if echo "$installed" | grep -qx "$ext"; then
      continue  # 既に install 済み (skip)
    fi
    log "install: $ext"
    if ! cursor --install-extension "$ext" >/dev/null 2>&1; then
      log "  ⚠️ install 失敗: $ext"
    fi
    newly=$((newly + 1))
  done < "$list_file"

  log "拡張機能 ${total} 件中 新規 install: ${newly} 件 (残りは既存スキップ)"
}

ensure_aws_sso_local_config() {
  local example="$SCRIPT_DIR/scripts/aws-sso-config.local.sh.example"
  local local_file="$SCRIPT_DIR/scripts/aws-sso-config.local.sh"

  if [[ -f "$local_file" ]]; then
    log "既に存在 (skip): $local_file"
    return 0
  fi

  cp "$example" "$local_file"
  log "雛形からコピー: $local_file"
  log "→ \$EDITOR $local_file で ACCOUNTS と SSO_START_URL を編集してください"
}

main() {
  section "Ghostty"
  ensure_symlink \
    "$SCRIPT_DIR/ghostty/config" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

  section "Cursor"
  ensure_symlink \
    "$SCRIPT_DIR/cursor/settings.json" \
    "$HOME/Library/Application Support/Cursor/User/settings.json"
  ensure_symlink \
    "$SCRIPT_DIR/cursor/keybindings.json" \
    "$HOME/Library/Application Support/Cursor/User/keybindings.json"

  section "Cursor 拡張機能"
  ensure_cursor_extensions

  section "zsh (~/.zshrc に source 行を追記)"
  ensure_zshrc_source_line

  section "scripts/aws-sso-config.local.sh (機微情報を保持するローカル設定)"
  ensure_aws_sso_local_config

  printf '\n完了。新しいシェルを起動するか `source ~/.zshrc` で設定を反映させてください。\n'
}

main "$@"
