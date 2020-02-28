#!/bin/sh

# masでアプリをインストール
for app in `sed '/^#/d' app_list/mas.txt`; do
  if ! type ${app} > /dev/null 2>&1; then
    mas install ${app}
  else
    echo "Installed ${app}"
  fi
done
