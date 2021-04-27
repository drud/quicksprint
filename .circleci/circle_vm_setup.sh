#!/usr/bin/env bash

set -o errexit
set -x

# Basic tools

v=php7.4
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -qq
sudo apt-get install -y -qq coreutils jq zip ${v} ${v}-bcmath ${v}-curl ${v}-cgi ${v}-cli ${v}-common ${v}-fpm ${v}-gd ${v}-intl ${v}-json ${v}-mysql ${v}-mbstring  ${v}-opcache ${v}-soap ${v}-readline ${v}-xdebug ${v}-xml ${v}-xmlrpc ${v}-zip;

sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo php -r "unlink('composer-setup.php');"

if [ ! -d /home/linuxbrew/.linuxbrew/bin ] ; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
fi

echo "export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH" >>~/.bashrc

. ~/.bashrc

brew update
brew install mkcert drud/ddev/ddev

# install recent bats bash testing framework
BATS_TAG=v1.1.0
sudo rm -f /usr/local/bin/bats
cd /tmp && git clone https://github.com/bats-core/bats-core.git && cd bats-core && git checkout ${BATS_TAG} && sudo ./install.sh /usr/local
