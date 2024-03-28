#!/bin/bash -e

CURRENT_DIR=$PWD
function cleanup {
  cd $CURRENT_DIR
}
trap cleanup EXIT

###### Configure pwn tools ######
cd
sudo gem install one_gadget
pip install pwn capstone filebytes keystone-engine ropper pyvex shellen ROPgadget archinfo z3-solver

mkdir ~/.gdb
cd ~/.gdb
git clone --depth=1 https://github.com/jerdna-regeiz/splitmind
git clone --depth=1 https://github.com/pwndbg/pwndbg
cd pwndbg
cp -f .gdbinit ~

# tmux-specific conf created only for ssh sessions (linux inside mac)
if [[ ! -z "$SSH_TTY" ]]; then
cat > ~/.pwn.conf <<EOF
[context]
terminal=['tmux', 'neww']
EOF
fi
