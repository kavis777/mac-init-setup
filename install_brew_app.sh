#!/bin/bash

# Homebrewが未インストールならインストール
if ! command -v brew &>/dev/null; then
  echo "Homebrewをインストールします..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrewでアプリをインストール
while IFS= read -r app; do
  app="${app%%#*}"
  app="${app%"${app##*[![:space:]]}"}"
  [[ -z "$app" ]] && continue
  if brew list "$app" > /dev/null 2>&1; then
    echo "Already installed: $app"
  else
    echo "Installing: $app"
    # stdin を渡すと brew（依存のpost-install含む）が brew.txt の残りを読み込み、ループが黙って終わる
    if ! brew install "$app" < /dev/null; then
      echo "エラー: ${app} のインストールに失敗しました" >&2
      exit 1
    fi
  fi
done < app_list/brew.txt

# uv（Pythonツール管理）。dotfiles/scripts/claude-usage-alert が ~/.local/bin/uv を
# 絶対パスで呼ぶため、brew ではなく公式インストーラで ~/.local/bin に入れる。
# PATH は dotfiles の .zshrc が通すので、インストーラにはシェル設定を書き換えさせない
if [[ ! -x "$HOME/.local/bin/uv" ]]; then
  echo "Installing: uv"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi
if ! "$HOME/.local/bin/uv" tool list 2>/dev/null | grep -q '^claude-monitor '; then
  echo "Installing: claude-monitor (uv tool)"
  "$HOME/.local/bin/uv" tool install claude-monitor || echo "⚠ claude-monitor のインストールに失敗しました (スキップ)" >&2
fi

# ローカル開発用のミドルウェアをログイン時に自動起動させる
for service in postgresql@14 redis nginx; do
  brew services start "$service" || echo "⚠ ${service} の起動に失敗しました (スキップ)" >&2
done
