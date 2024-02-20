#!/bin/bash

if command -v cargo >&/dev/null; then
	cargo install eza
else
	wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg

	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

	sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
	return 0
	if command -v nala &>/dev/null; then
		sudo nala update
		sudo nala install -y eza
	else
		sudo apt update
		sudo apt install -y eza
	fi
fi
