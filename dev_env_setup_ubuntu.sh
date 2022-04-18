#!/bin/bash
echo "Splashkit Translator Ubuntu development environment setup"

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

# ????
#sudo add-apt-repository universe
#sudo apt-get update

#sudo apt-get install ca-certificates curl gnupg lsb-release
#sudo apt -y install apt-transport-https ca-certificates curl software-properties-common

#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#echo \
  #"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  #$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Add repository for docker compose
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose

# Run dockerd in the background
sudo dockerd > /dev/null 2>&1 &

sudo docker-compose -d --

# Build docker image
docker build --tag headerdoc -f Dockerfile .

# Setup VS Code to write commit messages
git config --global core.editor "code --wait"

#docker run --rm -v /home/skt/translator/splashkit-core:/splashkit/ headerdoc ./translate -i /splashkit/ -o /splashkit/generated -g python

#docker container prune -a
#docker system prune -a
