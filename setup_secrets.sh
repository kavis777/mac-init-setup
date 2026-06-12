#!/bin/bash

eval "$(/opt/homebrew/bin/brew shellenv)"

set -euo pipefail

# Bitwarden CLIを使ってシークレットを復元するスクリプト
# シークレットの定義は secrets.conf を参照

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRETS_CONF="$SCRIPT_DIR/secrets.conf"

# ---------- 前提チェック ----------

for cmd in bw jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "エラー: ${cmd} がインストールされていません (brew install ${cmd})"
    exit 1
  fi
done

if [[ ! -f "$SECRETS_CONF" ]]; then
  echo "エラー: $SECRETS_CONF が見つかりません"
  exit 1
fi

# ---------- Bitwarden ログイン・アンロック ----------

bw_status=$(bw status 2>/dev/null | jq -r '.status')

if [[ "$bw_status" == "unauthenticated" ]]; then
  echo "Bitwardenにログインします..."
  bw login
fi

if [[ "$bw_status" != "unlocked" ]]; then
  echo "Bitwardenの保管庫をアンロックします..."
  export BW_SESSION
  BW_SESSION=$(bw unlock --raw)
fi

bw sync

# ---------- ハンドラー ----------

handle_json() {
  local bw_item="$1"
  local target_file="${2/#\~/$HOME}"
  local jq_path="$3"

  if [[ ! -f "$target_file" ]]; then
    echo "⚠ ${target_file} が存在しません (スキップ: ${bw_item})"
    return
  fi

  local value
  value=$(bw get password "$bw_item" 2>/dev/null) || true

  if [[ -n "$value" ]]; then
    local tmp
    tmp=$(jq --arg v "$value" "$jq_path = \$v" "$target_file")
    echo "$tmp" > "$target_file"
    echo "✔ $bw_item → $jq_path"
  else
    echo "⚠ Bitwardenに '${bw_item}' が見つかりません (スキップ)"
  fi
}

handle_gh() {
  local bw_item="$1"

  if ! command -v gh &>/dev/null; then
    echo "⚠ gh がインストールされていません (スキップ: ${bw_item})"
    return
  fi

  if gh auth status &>/dev/null; then
    echo "✔ GitHub CLI は認証済みです"
    return
  fi

  local value
  value=$(bw get password "$bw_item" 2>/dev/null) || true

  if [[ -n "$value" ]]; then
    echo "$value" | gh auth login --with-token
    echo "✔ GitHub CLI を認証しました"
  else
    echo "⚠ Bitwardenに '${bw_item}' が見つかりません (スキップ)"
  fi
}

handle_ssh() {
  local bw_item="$1"

  local notes
  notes=$(bw list items --search "$bw_item" 2>/dev/null | jq -r '.[0].notes // empty') || true

  if [[ -z "$notes" ]]; then
    echo "⚠ Bitwardenに '${bw_item}' が見つかりません (スキップ)"
    return
  fi

  mkdir -p ~/.ssh
  chmod 700 ~/.ssh

  local current_file="" current_content=""

  restore_file() {
    if [[ -n "$current_file" && -n "$current_content" ]]; then
      if [[ ! -f "$HOME/.ssh/$current_file" ]]; then
        printf '%s\n' "$current_content" > "$HOME/.ssh/$current_file"
        if [[ "$current_file" != *.pub ]]; then
          chmod 600 "$HOME/.ssh/$current_file"
        else
          chmod 644 "$HOME/.ssh/$current_file"
        fi
        echo "✔ ~/.ssh/$current_file を復元しました"
      else
        echo "✔ ~/.ssh/${current_file} は既に存在します (スキップ)"
      fi
    fi
  }

  while IFS= read -r line; do
    if [[ "$line" =~ ^=====\ (.+)\ =====$ ]]; then
      restore_file
      current_file="${BASH_REMATCH[1]}"
      current_content=""
    elif [[ -n "$current_file" ]]; then
      if [[ -n "$current_content" ]]; then
        current_content+=$'\n'"$line"
      elif [[ -n "$line" ]]; then
        current_content="$line"
      fi
    fi
  done <<< "$notes"

  restore_file
}

# ---------- secrets.conf を処理 ----------

echo "=== シークレットを復元します ==="
echo ""

while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue

  type="${line%%:*}"
  rest="${line#*:}"

  case "$type" in
    json)
      bw_item="${rest%%:*}"
      rest="${rest#*:}"
      target_file="${rest%%:*}"
      jq_path="${rest#*:}"
      handle_json "$bw_item" "$target_file" "$jq_path"
      ;;
    gh)
      handle_gh "$rest"
      ;;
    ssh)
      handle_ssh "$rest"
      ;;
    *)
      echo "⚠ 不明なタイプ: ${type} (スキップ: ${line})"
      ;;
  esac
done < "$SECRETS_CONF"

echo ""
echo "シークレットの復元が完了しました"
