#!/bin/sh

# 隠しファイル・フォルダを表示
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# dotfilesをホームディレクトリにクローン
git clone https://github.com/kavis777/dotfiles.git ~/dotfiles

# 各設定ファイルのシンボリックリンクをホームディレクトリに作成
ln -s ~/dotfiles/.gitconfig ~
ln -s ~/dotfiles/.gitignore_global ~
ln -s ~/dotfiles/zsh/.zshrc ~
ln -s ~/dotfiles/tmux/.tmux.conf ~
