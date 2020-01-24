#!/bin/sh

# HOMEBREW_CASK_OPTSの環境変数設定
if ! grep -E -q 'HOMEBREW_CASK_OPTS' ~/.bash_profile; then
  echo 'export HOMEBREW_CASK_OPTS="--appdir=/Applications"' >> ~/.bash_profile
  source ~/.bash_profile
fi

# caskでアプリをインストール
missing_formulae=()
desired_formulae=(`cat app_list/cask.txt`)
installed=`brew cask list`
for index in ${!desired_formulae[*]}
do
  formula=`echo ${desired_formulae[$index]} | cut -d' ' -f 1`
  if [[ -z `echo "${installed}" | grep "^${formula}$"` ]]; then
    missing_formulae=("${missing_formulae[@]}" "${desired_formulae[$index]}")
  else
    echo "Installed ${formula}"
  fi
done

if [[ "$missing_formulae" ]]; then
  list_formulae=$( printf "%s " "${missing_formulae[@]}" )

  echo "Installing missing Homebrew formulae..."
  brew cask install $list_formulae

  [[ $? ]] && echo "$(tput setaf 2)Installed missing formulae ✔︎$(tput sgr0)"
fi

echo "Cleanup Homebrew..."
brew cleanup
echo "$(tput setaf 2)Cleanup Homebrew complete. ✔︎$(tput sgr0)"

