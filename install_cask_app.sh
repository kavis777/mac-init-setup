#!/bin/bash

eval "$(/opt/homebrew/bin/brew shellenv)"

# 標準ユーザー（管理者権限なし）では /Applications に書き込めない。
# その場合は ~/Applications にインストールする。Spotlight/Raycast からは通常どおり起動できる。
# なお pkg形式のcask（session-manager-plugin / git-credential-manager / gcloud-cli / zoom）は
# インストーラ自体が管理者認証を求めるため、この回避策では入らない。失敗分は最後に一覧で出す。
if [[ ! -w /Applications ]]; then
  mkdir -p "$HOME/Applications"
  export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"
  echo "ℹ /Applications に書き込めないため ~/Applications にインストールします"
fi

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
