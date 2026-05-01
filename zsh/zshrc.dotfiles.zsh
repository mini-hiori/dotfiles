#!/usr/bin/env zsh
# zshrc.dotfiles.zsh
# dotfiles リポジトリ由来の zsh 設定。
# 利用者の ~/.zshrc からこのファイルを source して使う想定。
# リポジトリ root の install.sh を実行すると、~/.zshrc に以下の 1 行が自動追記される:
#   source "$HOME/dotfiles/zsh/zshrc.dotfiles.zsh"  # ← clone 先のパスに置換される

# このファイル自身の dir (= dotfiles/zsh/) と dotfiles リポジトリのルートを解決
_DOTFILES_ZSH_DIR="${0:A:h}"
_DOTFILES_DIR="${_DOTFILES_ZSH_DIR:h}"

# scripts/ を PATH に追加 (再 source 時の重複追加を防ぐ)
case ":$PATH:" in
  *":${_DOTFILES_DIR}/scripts:"*) ;;
  *) export PATH="${_DOTFILES_DIR}/scripts:$PATH" ;;
esac

# 推奨エイリアス
# AWS SSO ログインヘルパー (export AWS_PROFILE をシェルに反映させるため source する)
alias awssso='source aws-sso-login.sh'
# Cursor 拡張機能リストを実機の現状で上書きエクスポート
alias cursor-ext-export='cursor-extensions-export.sh'

unset _DOTFILES_ZSH_DIR _DOTFILES_DIR
