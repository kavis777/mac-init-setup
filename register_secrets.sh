#!/bin/bash
set -euo pipefail

# 現在のマシンのシークレットをBitwardenに登録するスクリプト
# secrets.conf の定義に基づいて、既存の値を読み取りBitwardenに保存する

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

# ---------- ヘルパー ----------

bw_item_exists() {
  local name="$1"
  bw list items --search "$name" 2>/dev/null | jq -e ".[0] | select(.name == \"$name\")" &>/dev/null
}

create_or_update_login() {
  local name="$1" password="$2" notes="${3:-}"

  if bw_item_exists "$name"; then
    local item_id
    item_id=$(bw list items --search "$name" | jq -r ".[] | select(.name == \"$name\") | .id")
    bw get item "$item_id" \
      | jq --arg pw "$password" '.login.password = $pw' \
      | bw encode | bw edit item "$item_id" > /dev/null
    echo "✔ $name を更新しました"
  else
    bw get template item | jq \
      --arg name "$name" \
      --arg pw "$password" \
      --arg notes "$notes" \
      '.name = $name | .type = 1 | .login = {"username": null, "password": $pw} | .notes = $notes' \
      | bw encode | bw create item > /dev/null
    echo "✔ $name を新規登録しました"
  fi
}

create_or_update_secure_note() {
  local name="$1" notes="$2"

  if bw_item_exists "$name"; then
    local item_id
    item_id=$(bw list items --search "$name" | jq -r ".[] | select(.name == \"$name\") | .id")
    bw get item "$item_id" \
      | jq --arg notes "$notes" '.notes = $notes' \
      | bw encode | bw edit item "$item_id" > /dev/null
    echo "✔ $name を更新しました"
  else
    bw get template item | jq \
      --arg name "$name" \
      --arg notes "$notes" \
      '.name = $name | .type = 2 | .secureNote = {"type": 0} | .notes = $notes' \
      | bw encode | bw create item > /dev/null
    echo "✔ $name を新規登録しました"
  fi
}

# ---------- ハンドラー ----------

register_json() {
  local bw_item="$1"
  local target_file="${2/#\~/$HOME}"
  local jq_path="$3"

  if [[ ! -f "$target_file" ]]; then
    echo "⚠ ${target_file} が存在しません (スキップ: ${bw_item})"
    return
  fi

  local value
  value=$(jq -r "$jq_path // empty" "$target_file" 2>/dev/null) || true

  if [[ -z "$value" || "$value" == "<"* ]]; then
    echo "⚠ ${target_file} の ${jq_path} が未設定です (スキップ: ${bw_item})"
    return
  fi

  create_or_update_login "$bw_item" "$value" "対象: $target_file ($jq_path)"
}

register_gh() {
  local bw_item="$1"

  if ! command -v gh &>/dev/null; then
    echo "⚠ gh がインストールされていません (スキップ: ${bw_item})"
    return
  fi

  local token
  token=$(gh auth token 2>/dev/null) || true

  if [[ -z "$token" ]]; then
    echo "⚠ GitHub CLI が認証されていません (スキップ: ${bw_item})"
    return
  fi

  local username
  username=$(gh api user --jq '.login' 2>/dev/null) || true
  create_or_update_login "$bw_item" "$token" "GitHub PAT (user: ${username:-unknown})"
}

register_ssh() {
  local bw_item="$1"
  local notes=""

  for file in "$HOME"/.ssh/*; do
    local filename
    filename=$(basename "$file")
    [[ "$filename" == "known_hosts" || "$filename" == "known_hosts.old" || "$filename" == ".DS_Store" ]] && continue
    [[ -f "$file" ]] || continue

    notes+="===== $filename =====
$(cat "$file")

"
  done

  if [[ -z "$notes" ]]; then
    echo "⚠ ~/.ssh にファイルがありません (スキップ: ${bw_item})"
    return
  fi

  create_or_update_secure_note "$bw_item" "$notes"
}

# ---------- secrets.conf を処理 ----------

echo "=== 現在のシークレットをBitwardenに登録します ==="
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
      register_json "$bw_item" "$target_file" "$jq_path"
      ;;
    gh)
      register_gh "$rest"
      ;;
    ssh)
      register_ssh "$rest"
      ;;
    *)
      echo "⚠ 不明なタイプ: ${type} (スキップ: ${line})"
      ;;
  esac
done < "$SECRETS_CONF"

echo ""
echo "登録が完了しました"
