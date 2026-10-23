## 概要

新しい Mac を、AI（Claude Code）にほぼ自動でセットアップさせるためのリポジトリ。

- アプリ・CLI のインストール、dotfiles のリンク、システム設定、シークレットの復元、仕事のリポジトリの clone を行う
- 手順の本体は [CLAUDE.md](CLAUDE.md)。AI はこれを読んで上から順に実行し、
  パスワード入力・ブラウザ認証・macOS の許可ダイアログなど人にしかできない作業だけを頼んでくる

## 最初にやること（人）

1. Homebrew を入れる（Command Line Tools も一緒に入る）
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
2. Claude Code を入れてログインする
   ```
   brew install --cask claude-code
   claude
   ```
   （ログインが済んだら一度終了する）
3. このリポジトリを clone して、その中で Claude Code を起動する
   ```
   git clone https://github.com/kavis777/mac-init-setup.git ~/mac-init-setup
   cd ~/mac-init-setup && claude
   ```
4. 「新しい Mac のセットアップを進めて」と頼む

前の Mac が手元にあるうちに、前の Mac でも同じように AI を起動して「前の Mac でやることを進めて」と頼んでおく
（シークレットの Bitwarden 登録、Raycast の書き出し、.env 類の tar 作成など。詳細は CLAUDE.md）。

## 人がやる作業

AI が頼んでくるのは次のものだけ。

- Bitwarden のマスターパスワードが要るもの: `setup_secrets.sh`、`register_secrets.sh`、`jobcan sync-credential`
- sudo のパスワードが要る pkg 形式の cask の追加インストール
- ブラウザでの認証: GitHub、AWS SSO、gcloud、clasp、Docker、Codex、VS Code の設定同期、Dropbox
- macOS の許可ダイアログ: Karabiner-Elements のドライバ・入力監視
- GUI 操作: Raycast の設定の取り込み、AirDrop、スクリプトで変えられないシステム設定（Apple ID、解像度など）

## スクリプト

| スクリプト | 内容 |
|---|---|
| `install_brew_app.sh` | `app_list/brew.txt` の CLI、uv・claude-monitor、postgresql@14 / redis / nginx の自動起動、`~/.zprofile` の brew PATH |
| `install_cask_app.sh` | `app_list/cask.txt` の GUI アプリ |
| `config_setup.sh` | dotfiles などの clone、`~/dotfiles/links.conf` のシンボリックリンク、MCP 設定の雛形、LaunchAgents、`app_list/repos.txt` の仕事のリポジトリの clone |
| `install_asdf.sh` | `~/.tool-versions` の言語ランタイム、jobcan-cli の依存、clasp |
| `setup_macos.sh` | システム設定のうち defaults で変えられるもの |
| `setup_secrets.sh` | Bitwarden からシークレット・設定ファイル・SSH 鍵を復元 |
| `register_secrets.sh` | 今のマシンのシークレットを Bitwarden に登録（前の Mac で実行） |

`app_list/` のうち `cask_not.txt` は cask で入れないアプリ、`cask_private.txt` はプライベート PC だけで入れるアプリのメモ（スクリプトからは読まない）。

## シークレットの管理

シークレット（API トークン、SSH 鍵等）は Bitwarden CLI で管理している。定義は `secrets.conf`。

**新しいシークレットを追加する場合:**

1. `secrets.conf` に1行追加する
2. `sh register_secrets.sh` で現在の値を Bitwarden に登録する

```
# 例: 新しいMCPサーバーのトークンを追加（JSONの特定パスに注入）
json:claude-newservice-token:~/.claude.json:.mcpServers.newservice.env.API_TOKEN

# 例: 1行のトークンを平文ファイルとして置く場合（chmod省略時は600）
file:newservice-token:~/.config/newservice/token:600
```

SSH 鍵は `~/.ssh/` 配下の `known_hosts` 以外の全ファイル（`.pem` 等も含む）がまとめて
Bitwarden のセキュアノート1件に入る。鍵を足したら `register_secrets.sh` を再実行する。

`.env` 類は頻繁に変わるので Bitwarden には入れず、移行のたびに tar で一度だけ運ぶ（CLAUDE.md の「前の Mac でやること」）。

## MCP サーバーの設定

Claude Code が実際に読むのは `~/.claude.json` だが、このファイルは `machineID` や `projects`
などローカル状態も持つため、丸ごと dotfiles で管理することはできない。

そのため `~/dotfiles/claude/claude-json.template` に **MCP サーバー定義だけ** を置き、
`config_setup.sh` が `mcpServers` のみを `~/.claude.json` にマージする。既存の定義があれば
そちらが優先され、不足しているサーバーだけが追加される。トークンは `<...>` のプレースホルダに
しておき、`setup_secrets.sh` が Bitwarden の値で置き換える。

MCP サーバーを増やしたときは、テンプレートに定義を足し、トークンがあれば `secrets.conf` にも
1行足すこと。

`youtrack-agile` MCP だけはローカルの `~/projects/youtrack-agile-mcp` を参照しているため、
`config_setup.sh` がこのリポジトリも clone する。

## brew でインストールしたパッケージ一覧を表示する方法

```
brew list --formula | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%s %d\n" {}' | xargs -I{} sh -c 'if [[ "{}" =~ " 0" ]]; then echo {};fi' | sed -e "s/ 0//"
```
