#!/bin/bash

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
#  -Do a git pull to ensure you have latest commits for core
#  -Pre-load docker images for the sprint toolkit:
#    -Drupal 8
#    -phpmyadmin
#    -Coud9 IDE
#    -Thelounge IRC client
#
# Press y to continue
# !!You don't need to hit enter!!.
####
${RESET}"
read -n1 INSTALL
if [[ ! $INSTALL =~ ^[Yy]$ ]]
then
    exit 1
fi

clear

if [[ "$OS" == "Darwin" ]]; then
    FILEBASE="ddev_macos"

    if ! 7z --version >/dev/null 2>&1; then
        printf "
        ${GREEN}
        ####
        # Installing 7zip so that we can extract archives.
        #
        # Press y to continue
        # !!You don't need to hit enter!!.
        #
        ####
        ${RESET}"
        read -n1 SEVEN
        if [[ ! $SEVEN =~ ^[Yy]$ ]]
        then
            exit 1
        fi

        cp ${CURRENT_DIR}/bin/$OS/7z /usr/bin
    fi

    if ! docker --version >/dev/null 2>&1; then
        printf "
        ${GREEN}
        ####
        # Installing docker so that ddev will work.
        #
        # Press y to continue
        # !!You don't need to hit enter!!.
        #
        ####
        ${RESET}"
        read -n1 SEVEN
        if [[ ! $SEVEN =~ ^[Yy]$ ]]
        then
            exit 1
        fi

        # Install and open Docker
        hdiutil attach -nobrowse "${CURRENT_DIR}/docker_installs/Docker.dmg"
        sleep 10
        cp -rp /Volumes/Docker/Docker.app /Applications/
        wait
        open -a /Applications/Docker.app
        hdiutil detach /Volumes/Docker
    fi

elif [[ "$OS" == "Linux" ]]; then
    FILEBASE="ddev_linux"

    if ! command -v 7z >/dev/null 2>&1; then
        printf "
        ${GREEN}
        ####
        # Installing 7zip so that we can extract archives.
        #
        # Press y to continue
        # !!You don't need to hit enter!!.
        #
        ####
        ${RESET}"
        read -n1 SEVEN
        if [[ ! $SEVEN =~ ^[Yy]$ ]]
        then
            exit 1
        fi

        cp ${CURRENT_DIR}/bin/$OS/7z /usr/local/bin
        cp ${CURRENT_DIR}/bin/$OS/7z.so /usr/local/bin
    fi

    if ! command -v docker >/dev/null 2>&1; then
        printf "${YELLOW}Docker is required for ddev. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
        printf "${YELLOW}See the Docker CE section at this page for linux installation instructions https://docs.docker.com/install/#server${RESET}\n"
    fi

    if ! command -v docker-compose >/dev/null 2>&1; then
        printf "${YELLOW}Docker Compose is required for ddev. Download and install docker-compose at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
        printf "${YELLOW}See the Docker CE section at this page for linux installation instructions https://docs.docker.com/install/#server${RESET}\n"
    fi
    
else
    printf "${RED}Sorry, this installer does not support your platform at this time.${RESET}\n"    
    exit 1
fi

echo "Installing docker images for ddev to use..."
bin/$OS/7z -xc $(ls ddev_tarballs/ddev_docker_images*.tar.xz) -so | docker load

if [ -f ddev_tarballs/docker_additions.tar.xz ]; then
    bin/$OS/7z -xc $(ls ddev_tarballs/docker_additions.tar.xz) -so | docker load
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

if which brew &&  [ -f `brew --prefix`/etc/bash_completion ]; then
    bash_completion_dir=$(brew --prefix)/etc/bash_completion.d
    cp /tmp/ddev_bash_completion.sh $bash_completion_dir/ddev
    printf "${GREEN}Installed ddev bash completions in $bash_completion_dir${RESET}\n"
    rm /tmp/ddev_bash_completion.sh
fi

mkdir -p ~/Sites/sprint
cp start_sprint.sh ~/Sites/sprint/
cp sprint.tar.xz ~/Sites/sprint/

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
