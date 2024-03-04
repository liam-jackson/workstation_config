#!/bin/bash

sudo apt update
sudo apt install fd-find
ln -s "$(which fdfind)" ~/.local/bin/fd
