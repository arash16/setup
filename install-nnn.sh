#!/bin/bash -e

OS=$(uname)
if [[ "${OS}" == "Linux" ]]; then
  sudo apt -y install pkg-config libncursesw5-dev libreadline-dev atool imagemagick unar

  # export COLORTERM=truecolor
  wget https://github.com/atanunq/viu/releases/latest/download/viu-x86_64-unknown-linux-musl -O $HOME/.local/bin/viu
  chmod +x $HOME/.local/bin/viu

  wget https://github.com/hackerb9/lsix/raw/master/lsix -O ~/.local/bin/lsix
  chmod +x ~/.local/bin/lsix
else
  brew install pkg-config coreutils unar ffmpegthumbnailer poppler atool bsdtar viu libmagic lsix
fi

curl -s https://api.github.com/repos/jarun/nnn/releases/latest \
  | grep -m1 "browser_download_url.*nnn-v.*.tar.gz" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -O /tmp/nnn.tar.gz -i -
cd /tmp/ && tar -xzf nnn.tar.gz && rm nnn.tar.gz && cd nnn-* && sudo make O_NERD=1 strip install
sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"
