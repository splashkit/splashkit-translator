#!/bin/bash
echo "Splashkit Translator Ubuntu development environment setup."

# Install VS code editor
sudo snap install --classic code

# Install git
sudo apt-get install git

# Change to current user directory and setup folder structure
cd ~
mkdir translator
cd translator

# Clone Thoth-tech repositories
git clone https://github.com/thoth-tech/splashkit-core.git
git clone https://github.com/thoth-tech/splashkit-translator.git

# Configure Docker Repository
sudo apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add repository for docker compose
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose

# Build docker image
docker build --tag headerdoc -f Dockerfile .

# Setup VS Code to as editor for commit messages
git config --global core.editor "code --wait"

# Install SplashKit
bash <(curl -s https://raw.githubusercontent.com/splashkit/skm/master/install-scripts/skm-install.sh)

# Setup complete message
echo "Setup complete."