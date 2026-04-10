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

# 各設定ファイルのシンボリックリンクをホームディレクトリに作成
mkdir -p ~/.config
ln -sf ~/dotfiles/.gitconfig ~
ln -sf ~/dotfiles/.gitignore_global ~
ln -sf ~/dotfiles/zsh/.zshrc ~
ln -sf ~/dotfiles/zsh/sheldon ~/.config
ln -sf ~/dotfiles/nvim ~/.config
