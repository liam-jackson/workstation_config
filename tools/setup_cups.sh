#!/bin/bash

echo "
echo "RPi Hostname: $(hostname)"
echo "RPi IP address: $(hostname -I)"

echo "Confirming cups installation... "

if [[ -z "$(dpkg --get-selections | grep 'cups')" ]]; then
    sudo apt update && sudo apt upgrade
    sudo apt install cups
else
    echo "Found cups!"
fi

sudo usermod -a -G lpadmin $(whoami)
sudo cupsctl --remote-any
sudo systemctl restart cups
" > cups_install.sh

chmod +x cups_install.sh

sftp liam@rpi-print-server.local

