#!/bin/bash

sudo apt-get -y update
sudo apt-get -y upgrade

# Install basic packages
sudo apt-get -y wget
sudo apt-get install -y git
sudo apt-get install -y unzip
sudo apt-get install -y curl
sudo apt-get install -y ghostscript
sudo apt-get install -y ripgrep
sudo apt-get install -y fd-find
sudo apt-get install -y luarocks
sudo apt-get install -y bear

# Install Python
sudo apt-get install -y python3
sudo apt-get install -y python3-venv
sudo apt-get install -y pip

# Install lazygit for Snacks.lazygit
wget https://github.com/jesseduffield/lazygit/releases/download/v0.53.0/lazygit_0.53.0_Linux_x86_64.tar.gz -P /tmp/
tar -xvf /tmp/lazygit_0.53.0_Linux_x86_64.tar.gz -C /tmp/
sudo mv /tmp/lazygit /usr/local/bin
touch ~/.config/lazygit/config.yml

# Install rust for rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

# Install viu from cargo
cargo install viu

# Install nvm & node for nvim-cortex-debug
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.nvm/nvm.sh
nvm install node
npm install -g neovim
