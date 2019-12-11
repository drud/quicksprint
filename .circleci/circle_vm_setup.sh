#!/usr/bin/env bash

set -o errexit
set -x

# Basic tools

sudo apt-get update -qq
sudo apt-get install -y -qq jq realpath zip

# Remove any existing docker
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update -qq
sudo apt-get install -qq docker-ce

if [ ! -d /home/linuxbrew/.linuxbrew/bin ] ; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
fi

echo "export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH" >>~/.bashrc

. ~/.bashrc

brew update && brew tap drud/ddev
brew install mkcert ddev composer php docker-compose

# install recent bats bash testing framework
BATS_TAG=v1.1.0
sudo rm -f /usr/local/bin/bats
cd /tmp && git clone https://github.com/bats-core/bats-core.git && cd bats-core && git checkout ${BATS_TAG} && sudo ./install.sh /usr/local
