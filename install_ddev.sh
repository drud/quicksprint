#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

clear

# Install provided ddev release
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
BINOWNER=$(ls -ld /usr/local/bin | awk '{print $3}')
USER=$(whoami)
SHACMD=""
FILEBASE=""
CURRENT_DIR=$PWD

#Explain what the script does
printf "
${GREEN}
####
# This script will install everything you need to participate in this sprint.
#
# Feel free to first inspect the script before continuing if you like.
#  -To do this just open it with a text editor
#
# It does the following:
#  -Install Docker for your OS if you don't have it already
#  -Install ddev by Drud Technology
#  -Copy required components to ~/Sites/sprint/
#  -Pre-loaded docker images for the sprint toolkit:
#    -Drupal 8
#    -phpmyadmin
#    -Cloud9 IDE
#    -Thelounge IRC client
#
# Press y to continue, or any other key to exit the script.
# !!You don't need to hit enter!!.
####
${RESET}"
read -n1 INSTALL
if [[ ! $INSTALL =~ ^[Yy]$ ]]
then
    printf "${RED}You didn't hit y or Y, exiting script${RESET}"
    exit 1
fi

clear

if [[ "$OS" == "Darwin" ]]; then
    FILEBASE="ddev_macos"

    if ! command -v docker >/dev/null 2>&1; then
        printf "
        ${RED}
        ####
        # You need to install Docker and have it running before executing this script.
        # The installer is likely provided in a docker_installs directory with this package.
        # Otherwise get it at https://docs.docker.com/docker-for-mac/release-notes/
        ####
        ${RESET}"
        exit 1
    else
        printf "
        ${GREEN}
        ####
        # ${YELLOW}Open Docker preferences, confirm the memory allocation is set to 3.0 GiB${GREEN}
        # ${YELLOW}on the Advanced tab, and that docker has fully restarted before continuing.${GREEN}
        #
        # Press y once Docker has restarted, or any other key to exit the script.
        # !!You don't need to hit enter!!.
        #
        ####
        ${RESET}"
        read -n1 DOCKMEM
        if [[ ! $DOCKMEM =~ ^[Yy]$ ]]
        then
            printf "${RED}You didn't hit y or Y, exiting script${RESET}"
            exit 1
        fi
    fi

elif [[ "$OS" == "Linux" ]]; then
    FILEBASE="ddev_linux"

    if ! docker --version >/dev/null 2>&1; then
        printf "${YELLOW}Docker is required for ddev. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
        printf "${YELLOW}See the Docker CE section at this page for linux installation instructions https://docs.docker.com/install/#server${RESET}\n"
    fi

    if ! docker-compose --version >/dev/null 2>&1; then
        printf "${YELLOW}Docker Compose is required for ddev. Download and install docker-compose at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
        printf "${YELLOW}See the Docker CE section at this page for linux installation instructions https://docs.docker.com/install/#server${RESET}\n"
    fi

else
    printf "${RED}Sorry, this installer does not support your platform at this time.${RESET}\n"
    exit 1
fi

echo ""
echo "Installing docker images for ddev to use..."
if [[ "$OS" == "Darwin" ]]; then
    gzip -dc $(ls ddev_tarballs/ddev_docker_images*.tar.xz) | docker load
elif [[ "$OS" == "Linux" ]]; then
    xzcat $(ls ddev_tarballs/ddev_docker_images*.tar.xz) | docker load
fi

if [ -f ddev_tarballs/docker_additions.tar.xz ]; then
    if [[ "$OS" == "Darwin" ]]; then
        gzip -dc $(ls ddev_tarballs/docker_additions.tar.xz) | docker load
    elif [[ "$OS" == "Linux" ]]; then
        xzcat $(ls ddev_tarballs/docker_additions.tar.xz) | docker load
    fi
fi

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

# Ensure ddev is in path
if [[ ! $PATH = *"usr/local/bin"* ]]; then
    echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile
    echo "export PATH=/usr/local/bin:$PATH" >> ~/.zshrc
    source ~/.bash_profile
fi


mkdir -p ~/Sites/sprint
cp start_sprint.sh ~/Sites/sprint/
cp sprint.tar.xz ~/Sites/sprint/
wait

printf "
${GREEN}
######
#
# Your ddev and the sprint kit are now ready to use,
# execute the following commands now to start:
#
# ${YELLOW}cd ~/Sites/sprint${GREEN}
# ${YELLOW}./start_sprint.sh${GREEN}
#
######
${RESET}
"
