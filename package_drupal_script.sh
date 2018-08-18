#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# This makes git-bash actually try to create symlinks.
# Use developer mode in Windows 10 so this doesn't require admin privs.
export MSYS=winsymlinks:nativestrict

# Maximise compression
export XZ_OPT=-9e
export GZIP=-9

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.
# It assumes it's being run in the repository root.

STAGING_DIR_NAME=drupal_sprint_package
STAGING_DIR_BASE=~/tmp
STAGING_DIR="$STAGING_DIR_BASE/$STAGING_DIR_NAME"
REPO_DIR=$PWD
QUICKSPRINT_RELEASE=$(git describe --tags --always --dirty)

echo "$QUICKSPRINT_RELEASE" >.quicksprint_release.txt

DOCKER_URLS="https://download.docker.com/mac/stable/Docker.dmg https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe https://github.com/docker/toolbox/releases/download/v18.06.0-ce/DockerToolbox-18.06.0-ce.exe"

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
BINOWNER=$(ls -ld /usr/local/bin | awk '{print $3}')
USER=$(whoami)

# Ensure 7z is installed
command -v 7z >/dev/null 2>&1 || { echo >&2 "${RED}I require 7z command but it's not installed. Aborting.${RESET}"; exit 1; }
# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
then
    echo "docker is running, continuing."
else
    echo "docker is not running and is required for this script, exiting."
    exit 1
fi


if [ -d "$STAGING_DIR" ] && [ ! -z "$(ls -A "$STAGING_DIR")" ] ; then
    printf "${RED}The staging directory $STAGING_DIR already has files. Deleting them and recreating everything.${RESET}"
    rm -rf "$STAGING_DIR"
    if [ -e "$STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.tar.gz" ] ; then
        rm "$STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.tar.gz"
    fi
    if [ -e "$STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.zip" ]; then
        rm "$STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.zip"
    fi
fi

SHACMD="sha256sum"
LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/drud/ddev/releases/latest)
# The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
LATEST_VERSION="$(echo ${LATEST_RELEASE} |  jq -r .tag_name)"
RELEASE_URL="https://github.com/drud/ddev/releases/download/$LATEST_VERSION"

echo "$LATEST_VERSION" >.ddev_version.txt

# Install the beginning items we need in the kit.
mkdir -p ${STAGING_DIR}
cp -r .ddev_version.txt .quicksprint_release.txt bin sprint start_sprint.* SPRINTUSER_README.md install_ddev.* ${STAGING_DIR}


# macOS/Darwin has a oneoff/weird shasum command.
if [ "$OS" = "Darwin" ]; then
    SHACMD="shasum -a 256"
fi

if ! docker --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker is required to use this package. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
fi

cd ${STAGING_DIR}

printf "
${GREEN}
####
# Shall we package docker installers for mac and windows with the archive?
#### \n${RESET}"

while true; do
    read -p "Include installers? (y/n): " INSTALL
    case ${INSTALL} in
        [Yy]* ) printf "${GREEN}# Downloading docker installers. \n#### \n${RESET}";
                mkdir -p docker_installs
                pushd docker_installs >/dev/null
                for dockerurl in ${DOCKER_URLS}; do
                    curl -sSL -O ${dockerurl}
                done
                popd >/dev/null
                break;;

        [Nn]* ) printf "${GREEN}# Continuing script without downloading Docker installers. \n### \n${RESET}"; 
                break;;

        * ) echo "Please answer y or n.";;

    esac
done

mkdir -p ddev_tarballs
TARBALL="ddev_docker_images.$LATEST_VERSION.tar.xz"
SHAFILE="$TARBALL.sha256.txt"
if [ ! -f "ddev_tarballs/$TARBALL" ] ; then
    curl --fail -sSL "$RELEASE_URL/$TARBALL" -o "ddev_tarballs/$TARBALL"
    curl --fail -sSL "$RELEASE_URL/$SHAFILE" -o "ddev_tarballs/$SHAFILE"
fi
pushd ddev_tarballs >/dev/null
${SHACMD} -c "$SHAFILE"
popd >/dev/null

# Download the ddev tarball/zipball
for item in macos linux windows_installer; do
    pwd
    SUFFIX=tar.gz
    if [ ${item} == "windows_installer" ] ; then
        SUFFIX=exe
    fi
    TARBALL="ddev_$item.$LATEST_VERSION.$SUFFIX"
    SHAFILE="$TARBALL.sha256.txt"

    if [ ! -f "ddev_tarballs/$TARBALL" ] ; then
        curl --fail -sSL "$RELEASE_URL/$TARBALL" -o "ddev_tarballs/$TARBALL"
        curl --fail -sSL "$RELEASE_URL/$SHAFILE" -o "ddev_tarballs/$SHAFILE"
    fi
    pushd ddev_tarballs >/dev/null
    ${SHACMD} -c $(basename "$SHAFILE")
    popd >/dev/null
done

# clone or refresh d8 clone
mkdir -p sprint
git clone --quiet https://git.drupal.org/project/drupal.git ${STAGING_DIR}/sprint/drupal8
pushd ${STAGING_DIR}/sprint/drupal8 >/dev/null
cp ${REPO_DIR}/example.gitignore ${STAGING_DIR}/sprint/drupal8/.gitignore

echo "Running composer install --quiet"
composer install --quiet

# Copy licenses and COPYING notice.
cp -r ${REPO_DIR}/licenses "$STAGING_DIR/"
cp ${REPO_DIR}/COPYING "$STAGING_DIR/"
popd >/dev/null

cd ${STAGING_DIR}

echo "Creating tar and zipballs"
# Create tar.xz archive without using xz command, so we can work on all platforms
pushd sprint >/dev/null && 7z a -ttar -so bogusfilename.tar . | 7z a -si -txz ../sprint.tar.xz >/dev/null && popd >/dev/null
rm -rf ${STAGING_DIR}/sprint

cd ${STAGING_DIR_BASE}
tar -czf drupal_sprint_package.${QUICKSPRINT_RELEASE}.tar.gz ${STAGING_DIR_NAME}
zip -9 -r -q drupal_sprint_package.${QUICKSPRINT_RELEASE}.zip ${STAGING_DIR_NAME}
rm -rf ${STAGING_DIR_NAME}/docker_installs
tar -czf drupal_sprint_package.no_docker.${QUICKSPRINT_RELEASE}.tar.gz ${STAGING_DIR_NAME}
zip -9 -r -q drupal_sprint_package.no_docker.${QUICKSPRINT_RELEASE}.zip ${STAGING_DIR_NAME}

wait

printf "${GREEN}####
# The built sprint tarballs and zipballs are now in ${YELLOW}$STAGING_DIR_BASE${GREEN}.
#
# Now deleting the staging directory.
####${RESET}"
rm -rf ${STAGING_DIR_NAME}
wait
printf "${GREEN}
# Finished
####${RESET}
"
