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
printf "Installing docker images for ddev to use...\n"

# Allow faster turnaround on testing by export QUICKSPRINT_SKIP_IMAGE_INSTALL=true
if [ -z "${QUICKSPRINT_SKIP_IMAGE_INSTALL:-}" ]; then
    if command -v xzcat >/dev/null; then
        xzcat ddev_tarballs/ddev_docker_images*.tar.xz | docker load
    elif [[ "$OS" == "Darwin" ]]; then
        gzip -dc ddev_tarballs/ddev_docker_images*.tar.xz | docker load
    else
        printf "${YELLOW}Unable to load ddev_docker_images. They will load at first 'ddev start'.${RESET}\n"
    fi
fi

TARBALL=""
case "$OS" in
    Linux)
        TARBALL=ddev_tarballs/ddev_linux.${DDEV_VERSION}.tar.gz
        ;;
    Darwin)
        TARBALL=ddev_tarballs/ddev_macos.${DDEV_VERSION}.tar.gz
        ;;
    MINGW64_NT*)
        echo ""
        # Assume if DDEV_INSTALL_DIR is set that we *do* need ddev on Windows, install it.
        # Otherwise, we'll do the install using the installer below.
        if [ ! -z "${DDEV_INSTALL_DIR:-}" ]; then
            TARBALL=ddev_tarballs/ddev_windows.${DDEV_VERSION}.tar.gz
        fi
        ;;
    *)
        printf "${RED}No ddev binary is available for ${OS}${RESET}\n"
        exit 2
        ;;

esac

if [ ! -z "$TARBALL" ] ; then
    tar -xzf ${TARBALL} -C /tmp
    chmod ugo+x /tmp/ddev

    if command -v ddev >/dev/null && [  -z "${DDEV_INSTALL_DIR:-}" ] ; then
        printf "\n${RED}A version of ddev already exists in $(command -v ddev); You may upgrade it using your normal upgrade technique. Not installing a new version.${RESET}\n"
    else
        # Calling script may have already set DDEV_INSTALL_DIR, otherwise we respect and use it.
        if [ ! -z "${DDEV_INSTALL_DIR:-}" ]; then
            # It's the responsibility of the caller to have created the directory
            # and to have added the directory to $PATH
            echo "Installing for tests into DDEV_INSTALL_DIR='${DDEV_INSTALL_DIR:-}'"
        fi
        DDEV_INSTALL_DIR=${DDEV_INSTALL_DIR:-/usr/local/bin}
        if [ ! -d ${DDEV_INSTALL_DIR:-} ] ; then
            echo "DDEV_INSTALL_DIR '${DDEV_INSTALL_DIR:-}' does not exist"
            exit 3
        fi
        printf "Ready to place ddev in directory ${DDEV_INSTALL_DIR:-}.\n"
        BINOWNER=$(ls -ld ${DDEV_INSTALL_DIR:-} | awk '{print $3}')

        if [[ "$BINOWNER" == "$USER" ]]; then
            mv -f /tmp/ddev ${DDEV_INSTALL_DIR:-}
        else
            printf "${YELLOW}Running \"sudo mv /tmp/ddev $DDEV_INSTALL_DIR\" Please enter your password if prompted.${RESET}\n"
            sudo mv /tmp/ddev ${DDEV_INSTALL_DIR:-}
        fi
    fi
fi
if ! command -v ddev >/dev/null && [[ "$OS" =~ "MINGW64" ]] ; then
    printf "${YELLOW}Running the ddev_windows_installer. Please allow privileges as requested${RESET}\n"
    # Silent install of ddev for windows
    cmd //c $PWD/ddev_tarballs/ddev_windows_installer.${DDEV_VERSION}.exe //S
    printf "${GREEN}Installed ddev using the ddev_windows_installer. It may not be in your PATH until you open a new window.${RESET}\n"
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

