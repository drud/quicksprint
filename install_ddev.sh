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
USER=$(whoami)
SHACMD=""
FILEBASE=""
CURRENT_DIR=$PWD

# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
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
#  -Install Drud Technology's ddev local development tool
#  -Copy required components to ~/sprint
#  -Pre-loads docker images for the sprint toolkit:
#
####
${RESET}"

echo ""
echo "Installing docker images for ddev to use..."
if [ $OS = "MINGW64_NT-10.0" ] ; then PATH="./bin/windows:$PATH"; fi


if command -v 7z; then
    7z x ddev_tarballs/ddev_docker_images.*.tar.xz -so | docker load
elif command -v xzcat; then
    xzcat ddev_tarballs/ddev_docker_images*.tar.xz | docker load
elif [[ "$OS" == "Darwin" ]]; then
    gzip -dc ls ddev_tarballs/ddev_docker_images*.tar.xz | docker load
else
    echo "${YELLOW}Unable to load ddev_docker_images. They will load at first 'ddev start'.${RESET}"
fi


TARBALL=""
case "$OS" in
    Linux)
        TARBALL=ddev_tarballs/ddev_linux*.tar.gz
        ;;
    Darwin)
        TARBALL=ddev_tarballs/ddev_macos*.tar.gz
        ;;
    MINGW64_NT-10.0)
        echo "${YELLOW}PLease use the ddev_windows_installer provided with this package to install ddev${RESET}"
        ;;
    *)
        echo "${RED}No ddev binary is available for $OS${RESET}"
        exit 2
        ;;

esac

if [ ! -z "$TARBALL" ] ; then
    tar -xzf ${TARBALL} -C /tmp
    chmod ugo+x /tmp/ddev

    if command -v ddev >/dev/null ; then
        printf "A version of ddev already exists in $(command -v ddev); please update it using your normal technique. Not installing a new version."
    else
        DDEV_TARGET_DIR=/usr/local/bin
        if [ ! -d $DDEV_TARGET_DIR ] ; then
            # Windows git-bash won't have a /usr/local/bin, but /usr/bin is likely writable.
            DDEV_TARGET_DIR=/usr/bin
        fi
        printf "Ready to place ddev in directory $DDEV_TARGET_DIR.\n"
        BINOWNER=$(ls -ld $DDEV_TARGET_DIR | awk '{print $3}')

        if [[ "$BINOWNER" == "$USER" ]]; then
            mv -f /tmp/ddev $DDEV_TARGET_DIR
        else
            printf "${YELLOW}Running \"sudo mv /tmp/ddev $DDEV_TARGET_DIR\" Please enter your password if prompted.${RESET}\n"
            sudo mv /tmp/ddev $DDEV_TARGET_DIR
        fi
    fi
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
