#!/bin/sh

# Homebrewのインストール
if ! type brew > /dev/null 2>&1; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Homebrewでアプリをインストール
for app in `cat app_list/brew.txt`; do
  if ! type ${app} > /dev/null 2>&1; then
    brew install ${app}
  else
    echo "Installed ${app}"
  fi
done

# ------------------------------------------------------------

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

# ------------------------------------------------------------

# masでアプリをインストール
for app in `sed '/^#/d' app_list/mas.txt`; do
  if ! type ${app} > /dev/null 2>&1; then
    mas install ${app}
  else
    echo "Installed ${app}"
  fi
done

# # ------------------------------------------------------------

# # nodebrewの環境変数設定
# if ! grep -E -q '.nodebrew/current/bin' ~/.bash_profile; then
#   nodebrew setup
#   echo 'export PATH=$PATH:$HOME/.nodebrew/current/bin' >> ~/.bash_profile
#   source ~/.bash_profile
# fi

# # node.jsをインストール
# nodebrew install-binary v6.9.0
# nodebrew use v6.9.0
# source ~/.bash_profile

# # ------------------------------------------------------------

# # rbenvの環境変数設定
# if ! grep -E -q '/.rbenv/bin:' ~/.bash_profile; then
#   echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
#   echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
#   source ~/.bash_profile
# fi

# # Rubyのインストール
# rbenv install 2.5.1
# rbenv global 2.5.1
# rbenv exec gem install bundler
