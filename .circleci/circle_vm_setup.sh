#!/usr/bin/env bash

set -o errexit
set -x

# Basic tools

v=php7.1
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -qq
sudo apt-get install -y -qq jq realpath zip $v $v-bcmath $v-curl $v-cgi $v-cli $v-common $v-fpm $v-gd $v-intl $v-json $v-mysql $v-mbstring  $v-opcache $v-soap $v-readline $v-xdebug $v-xml $v-xmlrpc $v-zip;

# Remove existing docker
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

# docker-compose
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


curl -sS https://getcomposer.org/installer -o composer-setup.php
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
