#!/bin/bash

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
