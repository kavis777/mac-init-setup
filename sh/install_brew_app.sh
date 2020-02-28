#!/bin/sh

# Homebrewでアプリをインストール
for app in `cat app_list/brew.txt`; do
  if ! type ${app} > /dev/null 2>&1; then
    brew install ${app}
  else
    echo "Installed ${app}"
  fi
done
