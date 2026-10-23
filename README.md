## 概要

このリポジトリでは以下のことを行なっている。

- 最低限の環境設定
- 必要なアプリのインストール

## システム環境設定の変更

- Mission Control のデスクトップを 5 個まで追加
- Apple ID > ログインする
- トラックパッド > 「軌跡の速さ」を最速に変更
- ディスプレイ > 解像度 > サイズ調整の「スペースを拡大」に変更
- デスクトップと Dock > Mission Control > 「最新の使用状況に基づいて操作スペースを自動的に並べ替える」を OFF
- デスクトップと Dock > 「Dock を自動的に表示/非表示」を ON
- デスクトップと Dock > ホットコーナー > の左上に「ディスプレイをスリープさせる」を設定
- キーボード > キーボード > 「リピート入力認識までの時間」を短いに変更
- キーボード > ショートカット > 修飾キー の「Caps Lock キー」を「^Control」に変更
- キーボード > ショートカット > Mission Control の「デスクトップ N への切り替え」を ON
- キーボード > ショートカット > 入力ソース　の「前の入力ソースを選択」と「入力メニューの次のソースを選択」を OFF
- キーボード > ショートカット > Spotlight 　の「Spotlight 検索を表示」と「FInder の検索ウィンドウを表示」を OFF
- キーボード > ショートカット > スクリーンショット で各キャプチャのショートカットを「CMD + N」に変更
- バッテリー > オプション で「バッテリー使用時はディスプレイを少し暗くする」を OFF
- ロック画面 > 「使用していない場合はスクリーンセーバを開始」を 30 分後に設定
- ロック画面 > 「バッテリー駆動時に使用していない場合はディスプレイをオフにする」を 1 時間後に設定
- ロック画面 > 「電源アダプタ接続時に使用していない場合はディスプレイをオフにする」を 1 時間後に設定
- ロック画面 > 「スクリーンセーバの開始後またはディスプレイがオフになった後にパスワードを要求する」を 15 分後に設定
- コントロールセンター > バッテリー > 「割合（％）を表示」を ON
- 一般 > デフォルトの Web ブラウザ > Chrome

## 前提: 管理者権限

会社支給のMacでは `kawabe` が標準ユーザーに設定されており `sudo` が使えない
（`kawabe is not in the sudoers file` になる）。Homebrew のインストールと
pkg形式のcaskに管理者権限が要るため、**セットアップ中だけ `kawabe` を管理者に昇格させる**。

1. 管理者アカウント名を確認する（旧マシンでは `lcl` と `n-m028`）
   ```
   dscl . -read /Groups/admin GroupMembership
   ```
2. 昇格する。システム設定 > ユーザとグループ >（鍵を解除）> `kawabe` の
   「このコンピュータの管理を許可」を ON にして再ログイン。ターミナルなら
   ```
   su - <管理者アカウント名>
   sudo dseditgroup -o edit -a kawabe -t user admin
   exit
   ```
3. 確認する
   ```
   id -Gn | tr ' ' '\n' | grep -x admin && sudo -v && echo OK
   ```
4. 下記のセットアップ手順を実行する
5. 終わったら標準ユーザーに戻す
   ```
   sudo dseditgroup -o delete -a kawabe -t user admin
   ```

戻しても `brew` は使える（`/opt/homebrew` の所有者が `kawabe` 個人になるため）。
ただし `/Applications` には書けなくなるので、以後 cask で追加するGUIアプリは
`~/Applications` に入る。`install_cask_app.sh` が書き込み可否を自動判定する。

MDM（LanScope An）のポリシーで昇格が後から取り消される可能性があるため、
セットアップはまとめて一気に流すこと。

管理者権限がどうしても取れない場合は、以下3点だけ管理者に実行してもらえば残りは自力で進められる。
`/opt/homebrew` さえ譲渡されれば Homebrew 本体は tarball 展開で入り、以後 `brew install` に
sudo は不要（prefix が `/opt/homebrew` のままなのでビルド済みバイナリも効く）。

1. `xcode-select --install`（Command Line Tools）
2. `sudo mkdir -p /opt/homebrew && sudo chown -R kawabe:admin /opt/homebrew`
   → その後 `curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip-components 1 -C /opt/homebrew`
3. pkg形式のcask 4本: `session-manager-plugin` `git-credential-manager` `gcloud-cli` `zoom`

## 設定手順

任意のディレクトリに以下のリポジトリをクローンする。

```
git clone https://github.com/kavis777/mac-init-setup.git
```

mac-init-setup リポジトリ配下で以下のコマンドを順に実行する。

1. Homebrew パッケージ・uv（+ claude-monitor）のインストール、postgresql@14 / redis / nginx の自動起動登録
2. GUI アプリのインストール
3. dotfiles・ai-memory・my-memory 等のクローン、シンボリックリンク・MCP設定の雛形作成、LaunchAgents の登録（GitHub認証が未設定なら対話的にログイン）
4. 言語ランタイムのインストール（あわせて dotfiles の jobcan-cli の依存を入れる）
5. Bitwarden からシークレット・設定ファイル（`~/.aws/config` `~/.codex/config.toml` `~/.mulmoterminal/config.json` 等）を復元

```
sh install_brew_app.sh
sh install_cask_app.sh
sh config_setup.sh
sh install_asdf.sh
sh setup_secrets.sh
```

### 旧マシンでやっておくこと

新マシンは各リポジトリを GitHub から clone するため、移行前に旧マシンで以下を済ませておく。

1. `~/dotfiles` `~/ai-memory` `~/claude-personal` `~/claude-config` `~/my-memory` `~/my-memory/vault` をコミットして push する
2. `~/projects` 配下にリモート未設定のリポジトリがないか確認する
   ```
   for d in ~/projects/*/; do [ -d "$d/.git" ] || continue; git -C "$d" remote get-url origin >/dev/null 2>&1 || echo "リモートなし: $d"; done
   ```
   あわせて未push・未コミットの変更がないかも見る
   ```
   for d in ~/projects/*/; do [ -d "$d/.git" ] || continue; c=$(git -C "$d" status --porcelain | wc -l); p=$(git -C "$d" log --oneline --branches --not --remotes | wc -l); [ $c -gt 0 -o $p -gt 0 ] && echo "$(basename $d): 未コミット$c 未push$p"; done
   ```
3. git 管理外の秘密ファイルを新マシンへ移す（`.env*`、Rails の `config/master.key` 等）。clone では戻らない。
   `.env` は頻繁に変わるので Bitwarden には入れず、移行のたびに tar で一度だけ運ぶ
   1. git 管理外のものだけを洗い出す（追跡済みの `.env.*` と worktree の分は clone・worktree 作成で戻る）
      ```
      cd ~/projects && find . -maxdepth 3 -name node_modules -prune -o \( -name '.env*' -o -name master.key \) -type f -print \
        | grep -v -- '-wt[0-9]' | while read f; do git -C "$(dirname "$f")" ls-files --error-unmatch "$(basename "$f")" >/dev/null 2>&1 || echo "$f"; done
      ```
   2. 出てきたパスを `~/projects` からの相対パスのまま tar にする
      ```
      cd ~/projects && (umask 077; tar -czpf ~/Desktop/env-migration.tar.gz <上のパス…>)
      ```
   3. AirDrop で新マシンへ送り、各リポジトリを clone した後に展開する（`-k` で既存ファイルは上書きしない）
      ```
      tar -xzpkf ~/Downloads/env-migration.tar.gz -C ~/projects
      ```
   4. 両マシンの tar を削除する
4. 現在のシークレットを Bitwarden に登録する: `sh register_secrets.sh`
5. `brew leaves` / `brew list --cask` / `/Applications` と `app_list/` の差分を確認して反映する

## 手動でやること

- App Store を起動して必要なアプリをインストール
- Dropbox
  - アプリを起動してログイン
- zsh のコマンド履歴（引き継ぎたい場合のみ）
  - 旧マシンから直接コピーする
    ```
    scp 旧マシン:~/.zsh_history ~/.zsh_history
    ```
  - かつては `~/Dropbox/Apps/zsh/.zsh_history` へのシンボリックリンクで共有していたが、
    現在は各マシンのローカルファイルで運用している（Dropbox側は2022年で更新停止）
- cmux（ターミナル。設定は dotfiles の `cmux/cmux.json` と `cmux/config.ghostty` がリンクされる）
  - アプリを起動して表示を確認するだけでよい
- VS Code
  - アプリを起動して設定を同期
- Raycast
  - 旧マシンの Raycast で Settings → Advanced → Export し、iCloud Drive に `Raycast <日付>.rayconfig` を置く
  - 新マシンでそのファイルを開いて取り込む（設定画面に Import はない。ランチャーの「Import Settings & Data」でも可）
- NeoVim
  - プラグインは lazy.nvim が初回起動時に自動で入れる（先に入れる場合: `nvim --headless "+Lazy! sync" +qa`）
- cask_not.txt にあるアプリを手動でインストール
- Karabiner-Elements を起動し、ドライバ・システム拡張・入力監視を許可する（管理者認証が必要。英数/かなの設定自体は dotfiles から入る）
- 各種CLIに再ログインする（トークンをBitwardenで持たない運用のもの）
  - AWS: `aws sso login --sso-session lclco`（プロファイル定義は `setup_secrets.sh` で復元される）
  - gcloud: `gcloud auth login`
  - clasp: `clasp login`
  - Docker: `docker login`
  - Codex: `codex login`
  - Cursor CLI: `cursor-agent login`
- ジョブカン CLI の認証情報を Bitwarden から Keychain に取り込む: `jobcan sync-credential`
- SSH鍵・gh認証は `setup_secrets.sh` で自動復元される（Bitwarden未登録の場合: `gh auth login --web`）
  - SSH鍵は `~/.ssh/` 配下の `known_hosts` 以外の全ファイル（`.pem` 等も含む）がまとめて
    Bitwarden のセキュアノート1件に入る。鍵を足したら `register_secrets.sh` を再実行する

### シークレットの管理

シークレット（APIトークン、SSH鍵等）は Bitwarden CLI で管理している。

**新しいシークレットを追加する場合:**

1. `secrets.conf` に1行追加する
2. `sh register_secrets.sh` で現在の値をBitwardenに登録する

```
# 例: 新しいMCPサーバーのトークンを追加（JSONの特定パスに注入）
json:claude-newservice-token:~/.claude.json:.mcpServers.newservice.env.API_TOKEN

# 例: 1行のトークンを平文ファイルとして置く場合（chmod省略時は600）
file:newservice-token:~/.config/newservice/token:600
```

### MCP サーバーの設定

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

**現在のマシンのシークレットをBitwardenに登録（バックアップ）:**

```
sh register_secrets.sh
```

**新しいマシンにシークレットを復元:**

```
sh setup_secrets.sh
```

### brew でインストールしたパッケージ一覧を表示する方法

ターミナルで以下のコマンドを実行する。

```
brew list --formula | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%s %d\n" {}' | xargs -I{} sh -c 'if [[ "{}" =~ " 0" ]]; then echo {};fi' | sed -e "s/ 0//"
```
