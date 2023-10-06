#!/bin/bash

sudo apt-get install imagemagick

mkdir -p lsix && cd lsix

wget https://github.com/hackerb9/lsix/archive/master.zip
unzip master.zip

sudo cp lsix-master/lsix /usr/local/bin/
sudo chmod +x /usr/local/bin/lsix

echo "xterm -ti vt340" >> ~/.Xresources
echo "xterm*decTerminalID    :   vt340" >> ~/.Xresources



