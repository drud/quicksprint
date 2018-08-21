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
DDEV_VERSION=$(cat ./.ddev_version.txt)

# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
then
    printf "docker is running, continuing."
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

# Explain what the script does
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
if [ ${OS} = "MINGW64_NT-10.0" ] ; then PATH="./bin/windows:$PATH"; fi


if command -v 7z >/dev/null; then
    7z x ddev_tarballs/ddev_docker_images.${DDEV_VERSION}.tar.xz -so | docker load
elif command -v xzcat >/dev/null; then
    xzcat ddev_tarballs/ddev_docker_images*.tar.xz | docker load
elif [[ "$OS" == "Darwin" ]]; then
    gzip -dc ls ddev_tarballs/ddev_docker_images*.tar.xz | docker load
else
    echo "${YELLOW}Unable to load ddev_docker_images. They will load at first 'ddev start'.${RESET}"
fi


TARBALL=""
case "$OS" in
    Linux)
        TARBALL=ddev_tarballs/ddev_linux.${DDEV_VERSION}.tar.gz
        ;;
    Darwin)
        TARBALL=ddev_tarballs/ddev_macos.${DDEV_VERSION}.tar.gz
        ;;
    MINGW64_NT-10.0)
        echo ""
        TARBALL=ddev_tarballs/ddev_windows.${DDEV_VERSION}.tar.gz
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

    if command -v ddev >/dev/null && [  -z "${DDEV_INSTALL_DIR}" ] ; then
        printf "${RED}A version of ddev already exists in $(command -v ddev); You may upgrade it using your normal upgrade technique. Not installing a new version.${RESET}"
    else
        # Calling script may have already set DDEV_INSTALL_DIR, otherwise we respect and use it.
        # Otherwise, try to use /usr/local/bin and then /usr/bin
        if [ ! -z "${DDEV_INSTALL_DIR:-}" ]; then
            # It's the responsibility of the caller to have created the directory
            # and to have added the directory to $PATH
            echo "Installing for tests into ${DDEV_INSTALL_DIR}"
        fi
        DDEV_INSTALL_DIR=${DDEV_INSTALL_DIR:-/usr/local/bin}
        if [ ! -d ${DDEV_INSTALL_DIR:-} ] ; then
            echo "DDEV_INSTALL_DIR '${DDEV_INSTALL_DIR}' does not exist"
            exit 3
        fi
        printf "Ready to place ddev in directory $DDEV_INSTALL_DIR.\n"
        BINOWNER=$(ls -ld ${DDEV_INSTALL_DIR:-} | awk '{print $3}')

        if [[ "$BINOWNER" == "$USER" ]]; then
            mv -f /tmp/ddev ${DDEV_INSTALL_DIR:-}
        else
            printf "${YELLOW}Running \"sudo mv /tmp/ddev $DDEV_INSTALL_DIR\" Please enter your password if prompted.${RESET}\n"
            sudo mv /tmp/ddev ${DDEV_INSTALL_DIR:-}
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
