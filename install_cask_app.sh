#!/bin/bash

# caskでアプリをインストール
missing=()
while IFS= read -r app; do
  [[ -z "$app" || "$app" == \#* ]] && continue
  if brew list --cask "$app" > /dev/null 2>&1; then
    echo "Already installed: $app"
  else
    missing+=("$app")
  fi
done < app_list/cask.txt

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Installing missing cask apps: ${missing[*]}"
  brew install --cask "${missing[@]}"
fi

echo "Cleanup Homebrew..."
brew cleanup
echo "$(tput setaf 2)Done ✔︎$(tput sgr0)"
