#!/bin/sh

# caskでアプリをインストール
missing_formulae=()
desired_formulae=(`cat app_list/cask.txt`)
installed=`brew list --cask`
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
  brew install --cask $list_formulae

  [[ $? ]] && echo "$(tput setaf 2)Installed missing formulae ✔︎$(tput sgr0)"
fi

echo "Cleanup Homebrew..."
brew cleanup
echo "$(tput setaf 2)Cleanup Homebrew complete. ✔︎$(tput sgr0)"

