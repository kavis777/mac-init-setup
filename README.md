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

## 設定手順

任意のディレクトリに以下のリポジトリをクローンする。

```
git clone https://github.com/kavis777/mac-init-setup.git
```

mac-init-setup リポジトリ配下で以下のコマンドを実行する。

```
sh install_brew_app.sh      # Homebrew パッケージ（bw, gh 等）
sh install_cask_app.sh      # GUI アプリ
sh setup_secrets.sh         # GitHub PAT・SSH鍵の復元（JSONシークレットはスキップ）
sh config_setup.sh          # dotfiles 等のクローン・シンボリックリンク
sh install_asdf.sh          # 言語ランタイム
sh setup_secrets.sh         # JSONシークレットの適用（settings.local.json が存在する状態で再実行）
```

## 手動でやること

- App Store を起動して必要なアプリをインストール
- Dropbox
  - アプリを起動してログイン
  - .zsh_hisotory の共有
    ```
    ln -s -f  ~/Dropbox/Apps/zsh/.zsh_history ~
    ```
- iTerm2
  - アプリを起動して、Settings > General > Settings の「Import All Settings and Data」で`~/Dropbox/Apps/iTerm2/iTerm2 State.itermexport`を選択する
  - Settings > General > Settings の「Load settings from a custom folder or URL」にチェックを入れて Path に/Users/kawabe/Dropbox/Apps/iTerm2 を選択して「Save changes」を「Manually」に変更する
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

### シークレットの管理

シークレット（APIトークン、SSH鍵等）は Bitwarden CLI で管理している。

**新しいシークレットを追加する場合:**

1. `secrets.conf` に1行追加する
2. `sh register_secrets.sh` で現在の値をBitwardenに登録する

```
# 例: 新しいMCPサーバーのトークンを追加
json:claude-newservice-token:~/.claude/settings.local.json:.mcpServers.newservice.env.API_TOKEN
```

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
