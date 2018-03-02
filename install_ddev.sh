#!/bin/bash
set -e

# Install latest ddev release

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
BINOWNER=$(ls -ld /usr/local/bin | awk '{print $3}')
USER=$(whoami)
SHACMD=""
FILEBASE=""

if [[ "$OS" == "Darwin" ]]; then
    FILEBASE="ddev_macos"
elif [[ "$OS" == "Linux" ]]; then
    FILEBASE="ddev_linux"
else
    printf "${RED}Sorry, this installer does not support your platform at this time.${RESET}\n"
    exit 1
fi

if ! docker --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker is required for ddev. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
fi

if ! docker-compose --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker Compose is required for ddev. Download and install docker-compose at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
fi

gzip -dc ddev_tarballs/
TARBALL="$(ls ddev_tarballs/$FILEBASE*.tar.gz)"

tar -xzf $TARBALL -C /tmp
chmod ugo+x /tmp/ddev

printf "Ready to place ddev in your /usr/local/bin.\n"

if [[ "$BINOWNER" == "$USER" ]]; then
    mv /tmp/ddev /usr/local/bin/
else
    printf "${YELLOW}Running \"sudo mv /tmp/ddev /usr/local/bin/\" Please enter your password if prompted.${RESET}\n"
    sudo mv /tmp/ddev /usr/local/bin/
fi

if which brew &&  [ -f `brew --prefix`/etc/bash_completion ]; then
	bash_completion_dir=$(brew --prefix)/etc/bash_completion.d
    cp /tmp/ddev_bash_completion.sh $bash_completion_dir/ddev
    printf "${GREEN}Installed ddev bash completions in $bash_completion_dir${RESET}\n"
    rm /tmp/ddev_bash_completion.sh
fi

rm /tmp/$TARBALL /tmp/$SHAFILE

printf "${GREEN}ddev is now installed. Run \"ddev\" to verify your installation and see usage.${RESET}\n"
