#!/bin/bash

eval "$(/opt/homebrew/bin/brew shellenv)"

# asdf 0.16 以降は `asdf global` が廃止され `asdf set -u` に置き換わった。
# ~/.tool-versions は dotfiles 管理のシンボリックリンクなので、存在する場合は
# それを真実の源として扱い、書き換えずに記載どおりインストールする。

TOOL_VERSIONS="$HOME/.tool-versions"

# プロジェクトごとに.node-versionや.ruby-versionを参照するように設定
if ! grep -q 'legacy_version_file' "$HOME/.asdfrc" 2>/dev/null; then
  echo 'legacy_version_file = yes' >> "$HOME/.asdfrc"
fi

add_plugin() {
  local tool="$1"
  if asdf plugin list 2>/dev/null | grep -qx "$tool"; then
    echo "Plugin already added: $tool"
  else
    echo "Adding plugin: $tool"
    asdf plugin add "$tool" || echo "⚠ プラグイン ${tool} の追加に失敗しました (スキップ)" >&2
  fi
}

# 常に使うプラグインは .tool-versions の有無に関わらず入れておく
for tool in nodejs ruby python; do
  add_plugin "$tool"
done

if [[ -f "$TOOL_VERSIONS" ]]; then
  echo "=== ~/.tool-versions に従ってインストールします ==="
  while read -r tool versions || [[ -n "$tool" ]]; do
    [[ -z "$tool" || "$tool" == \#* ]] && continue
    add_plugin "$tool"
    for version in $versions; do
      echo "Installing: $tool $version"
      asdf install "$tool" "$version" \
        || echo "⚠ ${tool} ${version} のインストールに失敗しました (スキップ)" >&2
    done
  done < "$TOOL_VERSIONS"
else
  echo "=== ~/.tool-versions が無いため最新版をインストールします ==="
  for tool in nodejs ruby; do
    if asdf install "$tool" latest; then
      asdf set -u "$tool" latest
    else
      echo "⚠ ${tool} のインストールに失敗しました (スキップ)" >&2
    fi
  done
fi

asdf reshim 2>/dev/null || true

echo "$(tput setaf 2)Done ✔︎$(tput sgr0)"
