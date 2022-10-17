## 概要

このリポジトリでは以下のことを行なっている。
* 最低限の環境設定
* 必要なアプリのインストール

## システム環境設定の変更

- Mission Controlのデスクトップを5個まで追加
- Mission Controlの「最新の使用状況に基づいて操作スペースを自動的に並べ替える」をOFF
- Mission Control > ホットコーナー　で画面左上でスリープの設定
- ディスプレイの解像度を変更
- Dockとメニューバー > バッテリー の「割合（％）を表示」をON
- キーボード > ショートカット > Mission Control の「デスクトップNへの切り替え」をON
- キーボード > ショートカット > 入力ソース　の「前の入力ソースを選択」をOFF
- キーボード > ショートカット > スクリーンショット で各キャプチャのショートカットを「CMD + N」に変更
- Mission Control > ホットコーナー でスリープの設定
- 一般 > デフォルトのWebブラウザ > Chrome
- バッテリー > バッテリー でディスプレイをオフにする時間を変更
- バッテリー > 電源アダプタ でディスプレイをオフにする時間を変更
- Dockとメニューバーで「Dockを自動的に表示/非表示」をON

## 設定手順

このリポジトリをクローンしてhomebrewをインストールした後にターミナルで以下のコマンドを実行する。

homebrewのインストールは以下から行う。
https://brew.sh/index_ja

```
git clone https://github.com/kavis777/mac-init-setup.git

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
- VS Code を起動して設定をインポート
- LayerXをダウンロード
  - https://yuhua-chen.github.io/LayerX/
- 英かなでキーリマップの設定

### fishの設定

brewでfishのインストール後にターミナルで以下のコマンドを実行する。
　
```
ln -s ~/dotfiles/.config/ ~
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

### brewでインストールしたパッケージ一覧の更新方法

ターミナルで以下のコマンドを実行する。
```
brew list -1
```

すると現在インストールしているパッケージが一覧で表示されるので、[difff](https://difff.jp/)で差分を確認して、手動で更新する。
