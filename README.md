## 概要

このリポジトリでは以下のことを行なっている。
* 最低限の環境設定
* 必要なアプリのインストール

## システム環境設定の変更

- Mission Controlのデスクトップを5個まで追加
- Apple ID > ログインする
- トラックパッド > 「軌跡の速さ」を最速に変更
- ディスプレイ > 解像度 > サイズ調整の「スペースを拡大」に変更
- デスクトップとDock > Mission Control > 「最新の使用状況に基づいて操作スペースを自動的に並べ替える」をOFF
- デスクトップとDock > 「Dockを自動的に表示/非表示」をON
- デスクトップとDock > ホットコーナー > の左上に「ディスプレイをスリープさせる」を設定
- キーボード > キーボード > 「リピート入力認識までの時間」を短いに変更
- キーボード > ショートカット > 修飾キー の「Caps Lockキー」を「^Control」に変更
- キーボード > ショートカット > Mission Control の「デスクトップNへの切り替え」をON
- キーボード > ショートカット > 入力ソース　の「前の入力ソースを選択」と「入力メニューの次のソースを選択」をOFF
- キーボード > ショートカット > Spotlight　の「Spotlight検索を表示」と「FInderの検索ウィンドウを表示」をOFF
- キーボード > ショートカット > スクリーンショット で各キャプチャのショートカットを「CMD + N」に変更
- バッテリー > オプション で「バッテリー使用時はディスプレイを少し暗くする」をOFF
- ロック画面 > 「使用していない場合はスクリーンセーバを開始」を30分後に設定
- ロック画面 > 「バッテリー駆動時に使用していない場合はディスプレイをオフにする」を1時間後に設定
- ロック画面 > 「電源アダプタ接続時に使用していない場合はディスプレイをオフにする」を1時間後に設定
- ロック画面 > 「スクリーンセーバの開始後またはディスプレイがオフになった後にパスワードを要求する」を15分後に設定
- コントロールセンター > バッテリー > 「割合（％）を表示」をON
- 一般 > デフォルトのWebブラウザ > Chrome

## 設定手順

以下のサイトからhomebrewのインストールを行う。
https://brew.sh/index_ja


任意のディレクトリに以下のリポジトリをクローンする。

```
git clone https://github.com/kavis777/mac-init-setup.git
```

mac-init-setupリポジトリ配下で以下のコマンドを実行する。

```
sh config_setup.sh
sh install_brew_app.sh
sh install_cask_app.sh
sh install_asdf.sh
```

## 手動でやること

- App Storeを起動して必要なアプリをインストール
- Dropbox
  - アプリを起動してログイン
  - .zsh_hisotoryの共有
    ```
    ln -s -f  ~/Dropbox/Apps/zsh/.zsh_history ~
    ```
- iTerm2
  - アプリを起動して、Settings > General > Settings の「Import All Settings and Data」で`~/Dropbox/Apps/iTerm2/iTerm2 State.itermexport`を選択する
  - Settings > General > Settings の「Load settings from a custom folder or URL」にチェックを入れてPathに/Users/kawabe/Dropbox/Apps/iTerm2を選択して「Save changes」を「Manually」に変更する
- VS Code
  - アプリを起動して設定を同期
- Raycast
  - アプリを起動して設定をインポート
- cask_not.txtにあるアプリを手動でインストール
- 英かなでキーリマップの設定
- [vim-plug](https://github.com/junegunn/vim-plug)のインストール

### brewでインストールしたパッケージ一覧を表示する方法

ターミナルで以下のコマンドを実行する。
```
brew list --formula | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%s %d\n" {}' | xargs -I{} sh -c 'if [[ "{}" =~ " 0" ]]; then echo {};fi' | sed -e "s/ 0//"
```

