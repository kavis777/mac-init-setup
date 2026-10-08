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
（`kawabe is not in the sudoers file` になる）。以下は管理者でないと実行できないため、
セットアップ開始前に情報システム部に依頼する。

1. **Command Line Tools のインストール**（`xcode-select --install` のダイアログで管理者認証）
2. **Homebrew 用ディレクトリの作成と譲渡**
   ```
   sudo mkdir -p /opt/homebrew
   sudo chown -R kawabe:admin /opt/homebrew
   ```
   これさえ済めば Homebrew 本体は tarball 展開で入れられ、以後の `brew install` に
   sudo は不要（prefix が `/opt/homebrew` のままなのでビルド済みバイナリも効く）
   ```
   curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip-components 1 -C /opt/homebrew
   ```
3. **pkg形式のcask 4本**: `session-manager-plugin` `git-credential-manager` `gcloud-cli` `zoom`
   （インストーラが管理者認証を求めるため）

セットアップ中だけ一時的に管理者権限をもらえるなら、上記は不要で手順どおり進められる。

なお `/Applications` にも書き込めないため、`install_cask_app.sh` は書き込み可否を自動判定して
`~/Applications` にインストールする。

## 設定手順

任意のディレクトリに以下のリポジトリをクローンする。

```
git clone https://github.com/kavis777/mac-init-setup.git
```

mac-init-setup リポジトリ配下で以下のコマンドを順に実行する。

1. Homebrew パッケージのインストール
2. GUI アプリのインストール
3. dotfiles 等のクローン・シンボリックリンク・MCP設定の雛形作成（GitHub認証が未設定なら対話的にログイン）
4. 言語ランタイムのインストール
5. Bitwarden からシークレットを復元

```
sh install_brew_app.sh
sh install_cask_app.sh
sh config_setup.sh
sh install_asdf.sh
sh setup_secrets.sh
```

### 旧マシンでやっておくこと

新マシンは各リポジトリを GitHub から clone するため、移行前に旧マシンで以下を済ませておく。

1. `~/dotfiles` `~/ai-memory` `~/claude-personal` `~/claude-config` `~/my-memory` をコミットして push する
2. `~/projects` 配下にリモート未設定のリポジトリがないか確認する
   ```
   for d in ~/projects/*/; do [ -d "$d/.git" ] || continue; git -C "$d" remote get-url origin >/dev/null 2>&1 || echo "リモートなし: $d"; done
   ```
3. 現在のシークレットを Bitwarden に登録する: `sh register_secrets.sh`
4. `brew leaves` / `brew list --cask` と `app_list/` の差分を確認して反映する

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
  - アプリを起動して設定をインポート
- NeoVim
  - [vim-plug](https://github.com/junegunn/vim-plug?tab=readme-ov-file#unix-linux)のインストール
  - vim を起動して`:PlugInstall`コマンドを実行
- cask_not.txt にあるアプリを手動でインストール
- 英かなでキーリマップの設定
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
