#!/bin/bash

# Homebrewが未インストールならインストール
if ! command -v brew &>/dev/null; then
  echo "Homebrewをインストールします..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrewでアプリをインストール
while IFS= read -r app; do
  app="${app%%#*}"
  app="${app%"${app##*[![:space:]]}"}"
  [[ -z "$app" ]] && continue
  if brew list "$app" > /dev/null 2>&1; then
    echo "Already installed: $app"
  else
    echo "Installing: $app"
    if ! brew install "$app"; then
      echo "エラー: ${app} のインストールに失敗しました" >&2
      exit 1
    fi
  fi
done < app_list/brew.txt
