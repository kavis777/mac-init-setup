#!bin/sh

# 隠しファイル・フォルダを表示
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# dotfilesをホームディレクトリにクローン
git clone https://github.com/kavis777/dotfiles.git ~/dotfiles

# gitの設定ファイルのシンボリックリンクをホームディレクトリに作成
ln -s ~/dotfiles/.gitconfig ~
ln -s ~/dotfiles/.gitignore_global ~
