#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

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

# Check Docker is running
if docker run -t busybox:latest ls >/dev/null
then
    printf "docker service running, continuing."
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

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
#  -Copy required components to ~/sprint/
#  -Pre-loaded docker images for the sprint toolkit:
#    -Drupal 8
#    -phpmyadmin
#
####
${RESET}"
while true; do
    read -p "Continue? (y/n): " INSTALL
    case $INSTALL in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

if ! docker run -t busybox:latest ls >/dev/null; then
    printf "
    ${RED}
    ####
    # You need to install Docker and have it running before executing this script.
    # The installer may be provided with this package.
    # Docker installation and troubleshooting information is at
    # https://ddev.readthedocs.io/en/latest/users/docker_installation/
    ####
    ${RESET}"
    exit 1
fi

echo ""
echo "Installing docker images for ddev to use..."
if [[ "$OS" == "Darwin" ]]; then
    gzip -dc $(ls ddev_tarballs/ddev_docker_images*.tar.xz) | docker load
elif [[ "$OS" == "Linux" ]]; then
    xzcat $(ls ddev_tarballs/ddev_docker_images*.tar.xz) | docker load
fi

TARBALL="$(ls ddev_tarballs/$FILEBASE*.tar.gz)"

tar -xzf $TARBALL -C /tmp
chmod ugo+x /tmp/ddev

printf "Ready to place ddev in your /usr/local/bin.\n"

if [[ "$BINOWNER" == "$USER" ]]; then
    mv -f /tmp/ddev /usr/local/bin/
else
    printf "${YELLOW}Running \"sudo mv /tmp/ddev /usr/local/bin/\" Please enter your password if prompted.${RESET}\n"
    sudo mv /tmp/ddev /usr/local/bin/ddev
fi

mkdir -p ~/sprint
cp start_sprint.sh ~/sprint
cp sprint.tar.xz ~/sprint

printf "
${GREEN}
######
#
# Your ddev and the sprint kit are now ready to use,
# execute the following commands now to start:
#
# ${YELLOW}cd ~/sprint${GREEN}
# ${YELLOW}./start_sprint.sh${GREEN}
#
######
${RESET}
"
