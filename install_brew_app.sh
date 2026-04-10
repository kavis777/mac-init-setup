#!/bin/bash

# Homebrewでアプリをインストール
while IFS= read -r app; do
  [[ -z "$app" || "$app" == \#* ]] && continue
  if brew list "$app" > /dev/null 2>&1; then
    echo "Already installed: $app"
  else
    echo "Installing: $app"
    brew install "$app"
  fi
done < app_list/brew.txt
