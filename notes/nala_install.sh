#!/usr/bin/zsh

#####################################################
### The install process for nala package manager: ###
#####################################################

# get source code from:
# https://gitlab.com/volian/volian-archive/-/releases

DOWNLOADS="${HOME}/Downloads"

curl "https://gitlab.com/volian/volian-archive/uploads/b20bd8237a9b20f5a82f461ed0704ad4/volian-archive-keyring_0.1.0_all.deb" --output "${DOWNLOADS}"
sha256sum "${DOWNLOADS}/volian-archive-keyring_0.1.0_all.deb"

curl "https://gitlab.com/volian/volian-archive/uploads/d6b3a118de5384a0be2462905f7e4301/volian-archive-nala_0.1.0_all.deb" --output "${DOWNLOADS}"
sha256sum "${DOWNLOADS}/volian-archive-nala_0.1.0_all.deb"

sudo apt install "${DOWNLOADS}/volian-archive-*.deb"
echo "deb-src https://deb.volian.org/volian/ scar main" | sudo tee -a "/etc/apt/sources.list.d/volian-archive-scar-unstable.list"

sudo apt update && sudo apt install nala

