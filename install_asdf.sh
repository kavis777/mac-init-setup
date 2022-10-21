#!/bin/sh

# プラグインの追加
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git

# 言語の追加
asdf install nodejs latest
asdf install ruby latest

# グローバル環境で使うバージョンを設定
asdf global nodejs latest
asdf global ruby latest

# プロジェクトごとに.node-versionや.ruby-versionを参照するように設定
echo 'legacy_version_file = yes' >> "${HOME}"/.asdfrc


