## 概要

このリポジトリでは以下のことを行なっている。
* 最低限の環境設定
* 必要なアプリのインストール

## システム環境設定の変更

- Mission Controlのデスクトップを5個まで追加
- Apple ID > ログインする
- トラックパッド > 「軌跡の速さ」を最速に変更
- ディスプレイ > 解像度 > サイズ調整の「スペースを拡大」に変更
- Mission Control > 「最新の使用状況に基づいて操作スペースを自動的に並べ替える」をOFF
- キーボード > キーボード > 「リピート入力認識までの時間」を短いに変更
- キーボード > ショートカット > Mission Control の「デスクトップNへの切り替え」をON
- キーボード > ショートカット > 入力ソース　の「前の入力ソースを選択」をOFF
- キーボード > ショートカット > スクリーンショット で各キャプチャのショートカットを「CMD + N」に変更
- バッテリー > バッテリー でディスプレイをオフにする時間を変更
- バッテリー > 電源アダプタ でディスプレイをオフにする時間を変更
- Dockとメニューバー > 「Dockを自動的に表示/非表示」をON
- Dockとメニューバー > バッテリー の「割合（％）を表示」をON
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
```

## 手動でやること

- homebrewのインストール & 環境変数の設定
- App Storeを起動して必要なアプリをインストール
- Dropboxのアプリを起動してログイン
  - 1Passwordの設定でDropbooxを参照
  - Dashの設定でDropbooxを参照
  - iTerm2の設定でDropboxを参照
    - https://zenn.dev/ryuu/articles/iterm2-sync-setting
  - .zsh_hisotoryの共有
    ```
    ln -s -f  ~/Dropbox/Apps/zsh/.zsh_history ~
    ```
- VS Code を起動して設定をインポート
- cask_not.txtにあるアプリを手動でインストール
- 英かなでキーリマップの設定

### fishの設定

brewでfishのインストール後にターミナルで以下のコマンドを実行する。
　
```
ln -s ~/dotfiles/.config/ ~
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

### brewでインストールしたパッケージ一覧を表示する方法

ターミナルで以下のコマンドを実行する。
```
brew list --formula | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%s %d\n" {}' | xargs -I{} sh -c 'if [[ "{}" =~ " 0" ]]; then echo {};fi' | sed -e "s/ 0//"
```

