
echo RPi Hostname: liam-AW
echo RPi IP address: 192.168.1.97 172.17.0.1 2600:4040:5c6e:8c00:a9a8:9c97:3a32:14f3 2600:4040:5c6e:8c00:47b5:8f4e:e835:e138 

echo Confirming cups installation... 

if [[ -z cups install cups-browsed install cups-bsd install cups-client install cups-common install cups-core-drivers install cups-daemon install cups-filters install cups-filters-core-drivers install cups-ipp-utils install cups-pk-helper install cups-ppdc install cups-server-common install libcups2:amd64 install libcupsfilters1:amd64 install python3-cups:amd64 install python3-cupshelpers install ]]; then
    sudo apt update && sudo apt upgrade
    sudo apt install cups
else
    echo Found cups!
fi

sudo usermod -a -G lpadmin liam
sudo cupsctl --remote-any
sudo systemctl restart cups

