#!/bin/bash

eval "$(/opt/homebrew/bin/brew shellenv)"

# ---------- 前提チェック ----------

for cmd in gh jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "エラー: ${cmd} がインストールされていません。先に install_brew_app.sh を実行してください。"
    exit 1
  fi
done

if ! gh auth status &>/dev/null; then
  echo "GitHub認証が必要です。ブラウザでログインしてください。"
  gh auth login
fi

# 隠しファイル・フォルダを表示
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# dotfilesをホームディレクトリにクローン
if [[ ! -d ~/dotfiles ]]; then
  git clone https://github.com/kavis777/dotfiles.git ~/dotfiles
fi

# VS Codeでキーを連打できるように設定
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# ~/dotfiles/links.conf から読み取ってシンボリックリンクを作成
while IFS=: read -r source target; do
  [[ -z "$source" || "$source" == \#* ]] && continue
  target="${target/#\~/$HOME}"
  mkdir -p "$(dirname "$target")"
  rm -rf "$target"
  ln -s ~/dotfiles/"$source" "$target"
done < ~/dotfiles/links.conf

# ~/.claude/settings.local.json がなければテンプレートから作成
if [[ ! -f ~/.claude/settings.local.json ]]; then
  mkdir -p ~/.claude
  cp ~/dotfiles/claude/settings.local.json.template ~/.claude/settings.local.json
  echo "トークンの設定は setup_secrets.sh で自動的に行われます"
fi

# ~/.claude.json のMCPサーバー定義をテンプレートから補完
# （~/.claude.json は machineID / projects などローカル状態も持つためリンクはせずマージする。
#   既存の定義が優先され、不足しているサーバーだけが追加される）
MCP_TEMPLATE=~/dotfiles/claude/claude-json.template
if [[ -f "$MCP_TEMPLATE" ]]; then
  [[ -f ~/.claude.json ]] || echo '{}' > ~/.claude.json
  mcp_tmp=$(mktemp)
  if sed "s|__HOME__|$HOME|g" "$MCP_TEMPLATE" \
    | jq -s '.[0] as $cur | .[1] as $tpl
             | $cur
             | .mcpServers = (($tpl.mcpServers // {}) + ($cur.mcpServers // {}))' \
        ~/.claude.json - > "$mcp_tmp"; then
    mv "$mcp_tmp" ~/.claude.json
    echo "✔ ~/.claude.json にMCPサーバー定義を補完しました（トークンは setup_secrets.sh で注入）"
  else
    echo "⚠ ~/.claude.json のMCP定義マージに失敗しました (スキップ)" >&2
    rm -f "$mcp_tmp"
  fi
fi

# youtrack-agile MCP サーバー（~/.claude.json から絶対パスで参照している）
mkdir -p ~/projects
if [[ ! -d ~/projects/youtrack-agile-mcp ]]; then
  git clone https://github.com/kavis777/youtrack-agile-mcp.git ~/projects/youtrack-agile-mcp
fi

# ai-memoryをホームディレクトリにクローン & セットアップ
if [[ ! -d ~/ai-memory ]]; then
  git clone https://github.com/kavis777/ai-memory.git ~/ai-memory
fi
bash ~/ai-memory/scripts/setup.sh --work

# claude-configをホームディレクトリにクローン & セットアップ
if [[ ! -d ~/claude-config ]]; then
  git clone https://github.com/lcl-bus/claude-config.git ~/claude-config
fi
bash ~/claude-config/setup.sh front

# claude-personal（個人用スキル・コマンド）をクローン & セットアップ
if [[ ! -d ~/claude-personal ]]; then
  git clone https://github.com/kavis777/claude-personal.git ~/claude-personal
fi
bash ~/claude-personal/setup.sh
