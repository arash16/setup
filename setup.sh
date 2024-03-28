#!/bin/bash -e

CURRENT_DIR=$PWD
function cleanup {
  cd $CURRENT_DIR
}
trap cleanup EXIT

export PATH="$HOME/.local/bin:$HOME/.asdf/bin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=true
git config --global core.compression 9

function gh_deb() {
  echo; echo "##### $1 #####"
  CPU=$(uname -m)
  [[ "$CPU" == "x86_64" ]] && CPU=amd64
  curl -s https://api.github.com/repos/$1/releases/latest \
  | grep -m1 "browser_download_url${2:-".*${CPU}.*deb"}" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -O /tmp/pkg.deb -i -
  sudo dpkg -i /tmp/pkg.deb
  rm /tmp/pkg.deb
}

function gh_pull() {
  echo; echo "##### $1 #####"
  if [[ ! -d "$2" ]]; then
    git clone --depth=1 "https://github.com/$1.git" $2
  fi
}

if [[ ! -f "/tmp/arsh-pre" ]]; then
  OS=$(uname)
  if [[ "${OS}" == "Linux" ]]; then
    sudo apt-get -y update
    sudo apt-get -y install binutils cmake zsh build-essential python3-dev python3-pip \
      ca-certificates curl xsel urlview vim vim-gtk3 tmux jq
    python3 -m pip install --upgrade setuptools pip

    # Install latest releases (debian releases are old)
    gh_deb lsd-rs/lsd
    gh_deb sharkdp/bat
    gh_deb sharkdp/fd
    gh_deb noborus/ov
    gh_deb httpie/cli '.*deb'
    gh_deb ajeetdsouza/zoxide
    gh_deb BurntSushi/ripgrep
    gh_deb Arinerron/heaptrace '.*deb'
    gh_pull junegunn/fzf $HOME/.fzf
    $HOME/.fzf/install

    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
    sudo chmod +x /usr/bin/yq

    wget https://raw.githubusercontent.com/todotxt/todo.txt-cli/master/todo.sh -O $HOME/.local/bin/todo.sh
  else
    if ! [ -x "$(command -v brew)" ]; then
      echo Homebrew not found
      exit
    fi

    brew install \
      coreutils curl gdb xsel urlview vim tmux todo-txt \
      bat fd fzf ripgrep zoxide lsd jq yq httpie
  fi

  cp .todo.cfg ~
  touch /tmp/arsh-pre
fi

###### Install oh-my-zsh ######
if [[ -z "$ZSH" ]]; then
  echo 'Restart and Run the script once again from inside your zsh shell'
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  exit
fi

###### Configure zsh and etc ######
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGINS="$ZSH_CUSTOM/plugins"
THEMES="$ZSH_CUSTOM/themes"
mkdir -p $PLUGINS
mkdir -p $THEMES
gh_pull "zsh-users/zsh-autosuggestions" "$PLUGINS/zsh-autosuggestions" 
gh_pull "zdharma-continuum/fast-syntax-highlighting" "$PLUGINS/fast-syntax-highlighting" 
gh_pull "marlonrichert/zsh-autocomplete" "$PLUGINS/zsh-autocomplete" 
gh_pull "romkatv/powerlevel10k" "$THEMES/powerlevel10k"
cp -f .zshrc ~

###### Install lang version manager ######
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
gh_pull asdf-vm/asdf "$HOME/.asdf"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add rust https://github.com/asdf-community/asdf-rust.git
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
# asdf install nodejs latest
# asdf install golang latest
# asdf install rust latest

# asdf global nodejs latest
# asdf global golang latest
# asdf global rust latest

# asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
# asdf plugin add php https://github.com/asdf-community/asdf-php.git
# asdf plugin add python https://github.com/asdf-community/asdf-python.git
# https://github.com/orgs/asdf-community/repositories?type=all


###### Config lsd ######
mkdir -p ~/.config/lsd/
cp -f lsd-config.yaml ~/.config/lsd/config.yaml

###### Configure vim ######
gh_pull "VundleVim/Vundle.vim" "$HOME/.vim/bundle/Vundle.vim"
cp -f .vimrc ~
vim +PluginInstall +qall

###### Configure tmux ######
cd
gh_pull "gpakosz/.tmux" "$HOME/.tmux"
gh_pull "tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
ln -s -f .tmux/.tmux.conf
cp -f $CURRENT_DIR/.tmux.conf.local ~
tmux start-server
tmux new-session -d
sleep 1
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server

# sudo sh -c "$(curl -fsSL https://get.docker.com)"
# sudo usermod -aG docker $USER && newgrp docker
