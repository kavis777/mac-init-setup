#!/bin/bash

eval "$(/opt/homebrew/bin/brew shellenv)"

# caskでアプリをインストール
missing=()
while IFS= read -r app; do
  app="${app%%#*}"
  app="${app%"${app##*[![:space:]]}"}"
  [[ -z "$app" ]] && continue
  if brew list --cask "$app" > /dev/null 2>&1; then
    echo "Already installed: $app"
  else
    missing+=("$app")
  fi
done < app_list/cask.txt

# 1つずつインストールする。まとめて渡すと1本の失敗で全体が止まるため
failed=()
for app in "${missing[@]}"; do
  echo "Installing: $app"
  brew install --cask "$app" || failed+=("$app")
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "⚠ インストールに失敗したアプリ: ${failed[*]}" >&2
fi

echo "Cleanup Homebrew..."
brew cleanup
echo "$(tput setaf 2)Done ✔︎$(tput sgr0)"
