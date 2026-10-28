# Mac セットアップ手順書（AI 向け）

このリポジトリで起動された AI は、この手順書に沿って Mac のセットアップを進める。
ユーザーは README の「最初にやること」だけを済ませてから AI を起動している。

## 進め方

- 上から順に自分で実行し、各ステップの「確認」まで済ませてから次へ進む。
  途中で止めてユーザーに確認を取らない。止まるのは 👤 の作業だけ
- 👤 は AI にはできない作業（パスワード入力、ブラウザ認証、macOS の許可ダイアログ、GUI 操作）。
  そこまで来たら、ユーザーが自分のターミナルにそのまま貼れるコマンドと、画面で押すものを具体的に示して待つ。
  👤 の作業は近いものをまとめて一度に頼む
- 時間のかかるスクリプト（brew・cask・clone）はバックグラウンドで実行し、終わったらログを読んで確認する
- スクリプトが失敗したら、出力を読んで原因を直し、直したらコミットして push まで行う
- Bitwarden のマスターパスワードは扱わない。`setup_secrets.sh` と `jobcan sync-credential` はユーザーに実行してもらう
- シークレットの値は画面に出さない。確認は存在・長さ・権限・形式だけで行う
- 最初に、前の Mac が手元にあるか、「前の Mac でやること」が済んでいるかをユーザーに聞く

## 新しい Mac でやること

### 1. コマンドラインツール

`bash install_brew_app.sh` を実行する。

- 確認: `app_list/brew.txt` の全項目が `brew list` に出る。postgresql@14 / redis / nginx が `brew services list` で started

### 2. GUI アプリ

`bash install_cask_app.sh` を実行する。

- pkg 形式の cask（gcloud-cli、session-manager-plugin、git-credential-manager、zoom、karabiner-elements、box-drive）は
  インストーラが sudo のパスワードを求めるため、AI のシェルでは失敗する。最後に出る「インストールに失敗したアプリ」を
  👤 `brew install --cask <失敗した cask…>` で入れてもらう
- google-chrome が「already an App」で失敗するのは、Homebrew 外で入っているだけなので無視してよい
- 確認: `app_list/cask.txt` の全項目が `brew list --cask` に出る（google-chrome を除く）

### 3. 設定ファイル・リポジトリ

1. `gh auth token` が失敗したら 👤 `gh auth login --web`
2. `bash config_setup.sh` を実行する。dotfiles・ai-memory・claude-config・claude-personal・my-memory の clone、
   `~/dotfiles/links.conf` のシンボリックリンク、MCP 設定の雛形、LaunchAgents、`app_list/repos.txt` の仕事のリポジトリの clone を行う
- 確認: `links.conf` の各リンク先が `~/dotfiles/<source>` を指している。`repos.txt` の全リポジトリが `~/projects/<置き場所>` にある

### 4. 言語ランタイム・npm の CLI

`bash install_asdf.sh` を実行する（`~/.tool-versions` の nodejs / python、jobcan-cli の依存、clasp）。
続けて Neovim のプラグインを入れる: `nvim --headless "+Lazy! sync" +qa`

- 確認: `asdf current` で全て Installed、`clasp --version`、`~/.local/share/nvim/lazy` にプラグインがある

### 5. システム設定

`bash setup_macos.sh` を実行する（Dock、ホットコーナー、キーリピート、Spotlight のショートカット OFF など）。
スクリプトで変えられないものは、7 の 👤 作業にまとめて頼む。

### 6. シークレット

👤 `sh ~/mac-init-setup/setup_secrets.sh`（Bitwarden のマスターパスワード入力が要る）

- 入力前に、左 ⌘ で英数にしておくよう伝える（かな入力のままだと復号エラーになる）
- 確認: `secrets.conf` の復元先が全てある（値は出さない）、`~/.claude.json` と `~/.claude/settings.local.json` が `jq empty` を通る、
  `~/.ssh` の鍵が `ssh-keygen -l` で読める
- `bustour-api` の `master.key` は clone 後でないと復元されない。3 が済んでいれば入る
- 「見つかりません」と出た項目は Bitwarden に未登録。前の Mac で `register_secrets.sh` をやり直してもらう

### 7. 👤 GUI・ブラウザでの作業（まとめて頼む）

AI が先に開けるものは開いておく（設定画面・ファイル）。

- **Karabiner-Elements**: アプリを起動し、ドライバ機能拡張・バックグラウンド実行・入力監視を許可
  （AI が `open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"` で設定画面を開く）
- **Raycast**: 前の Mac で書き出した `~/Library/Mobile Documents/com~apple~CloudDocs/Raycast <日付>.rayconfig` を
  AI が `open` で開き、ユーザーは取り込み画面で Import を押す
- **VS Code**: アカウントメニュー > 設定の同期を有効にする > 前の Mac と同じアカウントでサインイン > 「置き換え（Replace Local）」
- **Dropbox**: 起動してログイン
- **CLI のログイン**: `aws sso login --sso-session lclco` / `gcloud auth login` / `clasp login` / `docker login` / `codex login`
- **ジョブカン**: `jobcan sync-credential`（Bitwarden のマスターパスワードが要る）
- **スクリプトで変えられないシステム設定**:
  - Apple ID にログイン
  - Mission Control でデスクトップを 5 個に増やす
  - ディスプレイ > 解像度を「スペースを拡大」
  - キーボード > ショートカット > スクリーンショットの各ショートカットを ⌘ + 数字に変更
  - バッテリー > オプション > 「バッテリー使用時はディスプレイを少し暗くする」を OFF
  - ロック画面 > ディスプレイをオフにするまで（バッテリー・電源とも）1 時間、パスワードを要求するまで 15 分
  - 一般 > デフォルトの Web ブラウザ > Chrome
  - 通知 > Google Chrome で通知を許可（Slack は Chrome で使っており、ここがオフだとサイト側で許可していても通知が出ない）

確認（AI が行う）:

- Karabiner: `systemextensionsctl list` で `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice` が `[activated enabled]`、
  `/var/log/karabiner/core_service.log` に `Load .../karabiner.json` と `(grabbed)`。最後に左右 ⌘ 単押しの英数/かな、
  Caps Lock が Control、Shift+2 が `@` になるかをユーザーに試してもらう
- Raycast: `~/.config/raycast/extensions` に拡張機能が戻り、`~/Library/Application Support/com.raycast.macos/*.db-wal` が更新されている
  （設定 DB は暗号化されていて中身は読めないので、ホットキーはユーザーに試してもらう）
- VS Code: `~/Library/Application Support/Code/User/settings.json` があり、`~/.vscode/extensions` に拡張機能が入っている。
  同期ログ `~/Library/Application Support/Code/logs/<最新>/userDataSync.log` が `[AutoSync] Disabled.` だけなら同期は始まっていない
- CLI: `aws sts get-caller-identity`、`gcloud auth list`、`clasp show-authorized-user`、`~/.docker/config.json` の auths、`codex login status`
- ジョブカン: `security find-generic-password -s jobcan-cli` がある

### 8. .env 類

前の Mac で作った tar を 👤 AirDrop で `~/Downloads` に送ってもらう。

1. `tar -tzvf` で中身を一覧し、各パスの展開先リポジトリが `~/projects` にあるか照合する
2. 展開先があるものだけを `tar -xzpkf <tar> -C ~/projects <パス…>` で展開する（`-k` で既存ファイルを上書きしない）。
   展開先がないものはユーザーに要否を聞く
3. 展開したファイルを `chmod 600` し、`git check-ignore` で管理外であること、`git status` に差分が出ないことを確認する
4. `tar -xzOf <tar> <パス> | cmp - ~/projects/<パス>` で一致を確かめてから、`~/Downloads` の tar と展開済みフォルダを削除する。
   前の Mac の tar も消すようユーザーに伝える

### 9. 最終確認

- `~/mac-init-setup` と `~/dotfiles` に未コミット・未 push の変更がない（`git status -sb`）
- 1〜8 の確認項目を一覧にしてユーザーに報告する。ユーザーに試してもらうもの（キー入力・Raycast のホットキー）は分けて書く

## 前の Mac でやること

新しい Mac に移る前に、前の Mac でこのリポジトリを開いて AI を起動し、以下を進める。

1. `~/dotfiles` `~/ai-memory` `~/claude-personal` `~/claude-config` `~/my-memory` `~/my-memory/vault` に未コミット・未 push がないか確認し、あればユーザーに確認してから push する
2. `~/projects` 配下を確認する
   - リモート未設定のリポジトリ、未コミット・未 push の変更がないか
   - 実際に使っているリポジトリと `app_list/repos.txt` の差分（`git remote get-url origin` と置き場所）。差分があれば repos.txt を更新する
3. `brew leaves` / `brew list --cask` / `/Applications` と `app_list/` の差分を確認し、必要なものを一覧に反映する
4. 👤 `sh register_secrets.sh`（Bitwarden のマスターパスワードが要る）
5. 👤 Raycast > Settings > Advanced > Export で、書き出し先を iCloud Drive にする
6. .env 類の tar を作る。git 管理外のものだけを洗い出し、`~/projects` からの相対パスのまま固める
   ```
   cd ~/projects && find . \( -name node_modules -o -name .git -o -name .next -o -name vendor \) -prune -o -type f \
       \( -name '.env' -o -name '.env.*' -o -name '.envrc' -o -name '.dev.vars*' -o -name master.key \) -print \
     | grep -v -E -- '-wt[0-9]/|\.(example|sample|template)$' \
     | while read f; do git -C "$(dirname "$f")" ls-files --error-unmatch "$(basename "$f")" >/dev/null 2>&1 || echo "$f"; done
   cd ~/projects && (umask 077; tar -czpf ~/Desktop/env-migration.tar.gz <上のパス…>)
   ```
   👤 その tar を AirDrop で新しい Mac に送る
7. 変更したものをコミットして push する

## つまずきやすい点（2026-10 の移行で分かったこと）

- **シェルスクリプト**: README どおり `sh` で実行すると macOS の `/bin/sh` で動き、`echo` が `\n` を改行に展開する。
  ファイルへの書き出しは `printf '%s\n'` を使う。`while read` のループ内で `brew` や `bw` を呼ぶと stdin を読まれて
  ループが黙って終わるので、ループ内のコマンドは `< /dev/null`、ループ自体は fd 3 から読む
- **GitHub CLI**: `gh auth status` は API を叩くので、レート制限中は認証済みでも失敗する。判定は `gh auth token`
- **GitHub への接続は HTTPS**。`~/.ssh/id_rsa` は社内サーバー用で、`ssh -T git@github.com` が拒否されても問題ない
- **Karabiner**: 本体キーボードは US 配列。`virtual_hid_keyboard.keyboard_type_v2` は `ansi`（`jis` にすると Shift+数字の記号がずれる）。
  Karabiner 経由の入力には macOS の修飾キー設定が効かないので、Caps Lock → Control は `karabiner.json` の simple_modifications で行う
- **Bitwarden**: `bw unlock` の `The decryption operation failed` は、パスワードの打ち間違い（かな入力・配列ずれ）が原因のことが多い
- **Raycast**: 設定は暗号化 DB にあり dotfiles では管理できない。設定画面に Import ボタンはなく、`.rayconfig` を開くか、
  ランチャーの「Import Settings & Data」で取り込む。Dropbox の `Apps/Raycast` にあるのは 2024 年の古い書き出し
- **bustour-api の master.key**: 16 進数ではない文字が混じっているが正しい鍵（Rails は `[key].pack("H*")` で読む）。
  形式だけで「壊れている」と判断しない
- **cmd-eikana**（⌘英かな）は 2026-09 に Homebrew で無効化された。代わりに Karabiner-Elements を使う
