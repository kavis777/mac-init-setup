#!bin/sh

# 隠しファイル・フォルダを表示
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# powerline/fontsのインストール
git clone https://github.com/powerline/fonts.git
sh fonts/install.sh
rm -rf fonts


# dotfilesをホームディレクトリにクローン
git clone https://github.com/kavis777/dotfiles.git ~/dotfiles

# fishの設定
ln -s ~/dotfiles/.config/ ~
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish


# iTerm2の設定
rm ~/Library/Preferences/com.googlecode.iterm2.plist
ln -s ~/dotfiles/iTerm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
killall cfprefsd

