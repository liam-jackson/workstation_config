#!/bin/sh

if ! [ -L /bin/sgedit ]; then
    echo "sgedit wasn't there, trying to create symlink..."
    sudo ln -s "${WORKSTATION_DIR}/bin/sgedit.sh" '/bin/sgedit' || return 1
fi

if ! [ $# -gt 0 ]; then
    echo "No file(s) provided"
    return 0
fi

SUDO_EDITOR=gedit sudoedit "$@"

