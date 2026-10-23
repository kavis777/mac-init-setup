#!/bin/bash

# システム設定のうち defaults で変えられるものをまとめて設定する。
# 変えられないもの（Apple ID、解像度、pmset 系など）は CLAUDE.md の「人に頼む作業」に残している。
# 何度実行しても同じ結果になる。反映にはログアウトが必要なもの（トラックパッド・キーリピート）がある

# トラックパッド > 軌跡の速さ を最速
defaults write -g com.apple.trackpad.scaling -float 3

# キーボード > リピート入力認識までの時間 を短い
defaults write -g InitialKeyRepeat -int 15

# デスクトップと Dock > Dock を自動的に表示/非表示
defaults write com.apple.dock autohide -bool true

# Mission Control > 最新の使用状況に基づいて操作スペースを自動的に並べ替える を OFF
defaults write com.apple.dock mru-spaces -bool false

# ホットコーナー左上 > ディスプレイをスリープさせる（10）
defaults write com.apple.dock wvous-tl-corner -int 10
defaults write com.apple.dock wvous-tl-modifier -int 0

# ロック画面 > 使用していない場合はスクリーンセーバを開始 を 30 分後
defaults -currentHost write com.apple.screensaver idleTime -int 1800

# コントロールセンター > バッテリー > 割合（％）を表示
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# キーボードショートカット（com.apple.symbolichotkeys）
set_hotkey() {
  local id="$1" enabled="$2" params="$3"
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
    "<dict><key>enabled</key><$enabled/><key>value</key><dict><key>parameters</key><array>$params</array><key>type</key><string>standard</string></dict></dict>"
}
int3() { printf '<integer>%s</integer><integer>%s</integer><integer>%s</integer>' "$1" "$2" "$3"; }

# Spotlight 検索を表示 / Finder の検索ウィンドウを表示 を OFF（⌘Space は Raycast が使う）
set_hotkey 64 false "$(int3 65535 49 1048576)"
set_hotkey 65 false "$(int3 65535 49 1572864)"

# 入力ソース > 前の入力ソースを選択 / 入力メニューの次のソースを選択 を OFF
set_hotkey 60 false "$(int3 32 49 262144)"
set_hotkey 61 false "$(int3 32 49 786432)"

# Mission Control > デスクトップ 1〜5 への切り替え（Control + 1〜5）を ON
# デスクトップ自体を 5 個作るのは手作業（Mission Control で追加する）
desktop=118
for keycode in 18 19 20 21 23; do
  set_hotkey "$desktop" true "$(int3 65535 "$keycode" 262144)"
  desktop=$((desktop + 1))
done

# 変更を反映する
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
killall Dock 2>/dev/null || true
killall ControlCenter 2>/dev/null || true

echo "$(tput setaf 2)Done ✔︎$(tput sgr0)（トラックパッドとキーリピートはログアウト後に反映）"
