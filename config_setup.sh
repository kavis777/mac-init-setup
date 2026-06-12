#!/bin/bash

# ---------- 前提チェック ----------

if ! command -v gh &>/dev/null; then
  echo "エラー: gh がインストールされていません。先に install_brew_app.sh を実行してください。"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "エラー: GitHub CLI が認証されていません。先に setup_secrets.sh を実行してください。"
  exit 1
fi

# 隠しファイル・フォルダを表示
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# dotfilesをホームディレクトリにクローン
if [[ ! -d ~/dotfiles ]]; then
  git clone https://github.com/kavis777/dotfiles.git ~/dotfiles
fi

# VS Codeでキーを連打できるように設定
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# ~/dotfiles/links.conf から読み取ってシンボリックリンクを作成
while IFS=: read -r source target; do
  [[ -z "$source" || "$source" == \#* ]] && continue
  target="${target/#\~/$HOME}"
  mkdir -p "$(dirname "$target")"
  ln -sf ~/dotfiles/"$source" "$target"
done < ~/dotfiles/links.conf

# ~/.claude/settings.local.json がなければテンプレートから作成
if [[ ! -f ~/.claude/settings.local.json ]]; then
  mkdir -p ~/.claude
  cp ~/dotfiles/claude/settings.local.json.template ~/.claude/settings.local.json
  echo "トークンの設定は setup_secrets.sh で自動的に行われます"
fi

# ai-memoryをホームディレクトリにクローン & セットアップ
if [[ ! -d ~/ai-memory ]]; then
  git clone https://github.com/kavis777/ai-memory.git ~/ai-memory
fi
bash ~/ai-memory/scripts/setup.sh --work

# claude-configをホームディレクトリにクローン & セットアップ
if [[ ! -d ~/claude-config ]]; then
  git clone https://github.com/lcl-bus/claude-config.git ~/claude-config
fi
bash ~/claude-config/setup.sh front
