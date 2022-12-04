#!/bin/sh

# Homebrewでアプリをインストール
for app in $(cat app_list/brew.txt);
do
  brew list "${app}" > /dev/null 2>&1
  if test $? -eq 0;
  then
    echo "Installed ${app}"
  else
    brew install "${app}"
  fi
done
