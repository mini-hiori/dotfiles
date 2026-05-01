#!/usr/bin/env zsh
# aws-sso-login.sh - AWS SSO ログインヘルパー
#
# 番号でアカウントを選び、対応する AWS CLI プロファイルを自動作成 (なければ) して
# `aws sso login` を実行し、AWS_PROFILE をシェルにエクスポートする。
#
# 使い方:
#   awssso                       # 推奨。zsh/zshrc.dotfiles.zsh で alias 設定済 (install.sh 実行後)
#   source aws-sso-login.sh      # 直接呼ぶ場合 (export AWS_PROFILE のため必ず source する)
#
# セットアップ・前提条件は scripts/README.md を参照。

set +e
set +o pipefail  # パイプライン内のエラーを無視

# zsh configuration
setopt KSH_ARRAYS  # 0-based array indexing like bash

# このスクリプト自身の dir を解決。
# alias 経由 `source aws-sso-login.sh` で PATH lookup された場合、$0 は bare name のままで
# cwd 依存になるため、zsh プロンプト展開 `%x` (現在実行中のソースファイル絶対パス) を使う。
SCRIPT_DIR="${${(%):-%x}:A:h}"
LOCAL_CONFIG="$SCRIPT_DIR/aws-sso-config.local.sh"

# デフォルト値 (ローカル設定で上書き可能)
SSO_REGION="ap-northeast-1"

# ローカル設定 (.gitignore 対象) を読み込む
if [[ ! -f "$LOCAL_CONFIG" ]]; then
    echo "ローカル設定ファイルが見つかりません: $LOCAL_CONFIG"
    echo
    echo "テンプレートからコピーして自分の環境用に編集してください:"
    echo "  cp $SCRIPT_DIR/aws-sso-config.local.sh.example $LOCAL_CONFIG"
    return 1 2>/dev/null || exit 1
fi
source "$LOCAL_CONFIG"

# 必須項目の検証
if [[ ${#ACCOUNTS[@]} -eq 0 ]]; then
    echo "ACCOUNTS が空です。$LOCAL_CONFIG にアカウント情報を追加してください。"
    return 1 2>/dev/null || exit 1
fi
if [[ -z "$SSO_START_URL" ]]; then
    echo "SSO_START_URL が未設定です。$LOCAL_CONFIG を編集してください。"
    return 1 2>/dev/null || exit 1
fi

select_account() {
    echo "=== AWS アカウント選択 ==="
    local count=${#ACCOUNTS[@]}
    for (( i=1; i<=count; i++ )); do
        index=$((i-1))
        IFS=':' read -r account_id role env desc <<< "${ACCOUNTS[$index]}"
        echo "$i. $desc"
    done

    echo
    echo -n "番号を選択してください: "
    read choice

    index=$((choice-1))
    if [[ $index -lt 0 || $index -ge $count ]]; then
        echo "無効な選択です"
        return 1 2>/dev/null || exit 1
    fi

    IFS=':' read -r account_id role env desc <<< "${ACCOUNTS[$index]}"
    profile_name="${env}-${role}"

    echo "選択: $desc ($profile_name)"
    echo
}

configure_profile() {
    echo "プロファイル '$profile_name' を設定中..."

    # プロファイルが存在しない場合は作成
    if ! aws configure list-profiles 2>/dev/null | grep -q "^$profile_name$" 2>/dev/null; then
        aws configure set sso_start_url "$SSO_START_URL" --profile "$profile_name"
        aws configure set sso_region "$SSO_REGION" --profile "$profile_name"
        aws configure set sso_account_id "$account_id" --profile "$profile_name"
        aws configure set sso_role_name "$role" --profile "$profile_name"
        aws configure set region "$SSO_REGION" --profile "$profile_name"
        aws configure set output "json" --profile "$profile_name"
    fi
}

login_and_set() {
    echo "SSOログインを実行中..."
    aws sso login --profile "$profile_name"

    export AWS_PROFILE="$profile_name"
    echo
    echo "✅ 設定完了！"
    echo "プロファイル: $profile_name"
    echo "環境変数: AWS_PROFILE=$AWS_PROFILE"
    echo

    # 認証確認
    echo "認証確認中..."
    aws sts get-caller-identity
}

# メイン処理
select_account
configure_profile
login_and_set

echo "export AWS_PROFILE=$profile_name"

export AWS_PROFILE=$profile_name
