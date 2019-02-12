#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Base checkout should be of the 8.7.x branch
SPRINT_BRANCH=8.7.x

# This makes git-bash actually try to create symlinks.
# Use developer mode in Windows 10 so this doesn't require admin privs.
export MSYS=winsymlinks:nativestrict

# Maximise compression
export XZ_OPT=-9e

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.
# It assumes it's being run in the repository root.

STAGING_DIR_NAME=drupal_sprint_package
STAGING_DIR_BASE=~/tmp
STAGING_DIR="$STAGING_DIR_BASE/$STAGING_DIR_NAME"
REPO_DIR=$PWD
QUICKSPRINT_RELEASE=$(git describe --tags --always --dirty)

echo "$QUICKSPRINT_RELEASE" >.quicksprint_release.txt

TOOLBOX_LATEST_RELEASE="$(curl -L -s -H 'Accept: application/json' https://github.com/docker/toolbox/releases/latest | jq -r .tag_name | sed 's/^v//')"
TOOLBOX_DOWNLOAD_URL="https://github.com/docker/toolbox/releases/download/v${TOOLBOX_LATEST_RELEASE}/DockerToolbox-${TOOLBOX_LATEST_RELEASE}.exe"

GIT_LATEST_RELEASE="$(curl -L -s -H 'Accept: application/json' https://github.com/git-for-windows/git/releases/latest | jq -r .tag_name | sed 's/^v//; s/\.windows\.1//;')"
GIT_DOWNLOAD_URL="https://github.com/git-for-windows/git/releases/download/v${GIT_LATEST_RELEASE}.windows.1/Git-${GIT_LATEST_RELEASE}-64-bit.exe"


DOWNLOAD_URLS="https://download.docker.com/mac/stable/Docker.dmg https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe ${TOOLBOX_DOWNLOAD_URL} ${GIT_DOWNLOAD_URL}"

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
USER=$(whoami)

# Ensure zcat is installed
command -v zcat >/dev/null 2>&1 || { printf >&2 "${RED}zcat command is required but it's not installed. ('brew install xz' on macOS, 'apt-get install xz-utils' on Debian/Ubuntu) Aborting.${RESET}\n"; exit 1; }
# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
then
    echo "docker is running, continuing."
else
    echo "docker is not running and is required for this script, exiting."
    exit 1
fi

SHACMD="sha256sum"
LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/drud/ddev/releases/latest)
# The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
LATEST_VERSION="$(echo ${LATEST_RELEASE} |  jq -r .tag_name)"
RELEASE_URL="https://github.com/drud/ddev/releases/download/$LATEST_VERSION"

echo "$LATEST_VERSION" >.ddev_version.txt

# Remove anything in the ddev_tarballs directory that don't match current version.
ddev_tarballs="${STAGING_DIR}/ddev_tarballs"
mkdir -p ${ddev_tarballs}

# Remove anything in staging directory except ddev_tarballs.
# Chmod as on WIndows read-only stuff is often unremoveable
chmod -R u+w ${STAGING_DIR}/{*.md,install.sh,sprint,start_sprint.sh} || true
rm -rf ${STAGING_DIR}/{*.md,install.sh,sprint,start_sprint.sh}
# Remove anything in ddev_tarballs that is not the latest version
if [ -d "${ddev_tarballs}" ]; then
     find "${ddev_tarballs}" -type f -not -name "*${LATEST_VERSION}*" -exec rm '{}' \;
fi

# Install the beginning items we need in the kit.
cp -r .ddev_version.txt .quicksprint_release.txt sprint start_sprint.* *.md install.sh ${STAGING_DIR}


# macOS/Darwin has a oneoff/weird shasum command.
if [ "$OS" = "Darwin" ]; then
    SHACMD="shasum -a 256"
fi

if ! docker --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker is required to create package. Please install docker before attempting to use ddev.${RESET}\n"
fi

cd ${STAGING_DIR}

printf "
${GREEN}
####
# Package docker and other installers (Git For Windows, etc)?
#### \n${RESET}"

while true; do
    read -p "Include installers? (y/n): " INSTALL
    case ${INSTALL} in
        [Yy]* ) printf "${GREEN}# Downloading installers. \n#### \n${RESET}";
                mkdir -p installs
                pushd installs >/dev/null
                for download_url in ${DOWNLOAD_URLS}; do
                    echo "Downloading ${download_url##*/} from ${download_url}"
                    curl -sSL -O ${download_url}
                done
                popd >/dev/null
                break;;

        [Nn]* ) printf "${GREEN}# Continuing script without downloading installers. \n### \n${RESET}";
                break;;

        * ) echo "Please answer y or n.";;

    esac
done

pushd ${ddev_tarballs} >/dev/null
# Download the ddev tarballs if necessary; check to make sure they all have correct sha256.
for tarball in ddev_macos.$LATEST_VERSION.tar.gz ddev_linux.$LATEST_VERSION.tar.gz ddev_windows.$LATEST_VERSION.tar.gz ddev_windows_installer.$LATEST_VERSION.exe ddev_docker_images.$LATEST_VERSION.tar.xz; do
    shafile="${tarball}.sha256.txt"

    if ! [ -f "${tarball}" -a -f "${shafile}" ] ; then
        echo "Downloading ${tarball} ..."
        curl --fail -sSL "$RELEASE_URL/${tarball}" -o "${tarball}"
        curl --fail -sSL "$RELEASE_URL/$shafile" -o "${shafile}"
    fi
    ${SHACMD} -c "${shafile}"
done
popd >/dev/null

# clone or refresh d8 clone
mkdir -p sprint
git clone --config core.autocrlf=false --config core.eol=lf --quiet https://git.drupal.org/project/drupal.git ${STAGING_DIR}/sprint/drupal8 -b ${SPRINT_BRANCH}
pushd ${STAGING_DIR}/sprint/drupal8 >/dev/null
cp ${REPO_DIR}/example.gitignore ${STAGING_DIR}/sprint/drupal8/.gitignore

echo "Running composer install --quiet"
composer install --quiet
popd >/dev/null

# Copy licenses and COPYING notice.
cp -r ${REPO_DIR}/licenses ${REPO_DIR}/COPYING "$STAGING_DIR/"
cp ${REPO_DIR}/.quicksprint_release.txt $REPO_DIR/.ddev_version.txt "$STAGING_DIR/sprint"

cd ${STAGING_DIR}

echo "Creating sprint.tar.xz..."
# Create tar.xz archive using xz command, so we can work on all platforms
pushd sprint >/dev/null && tar -cJf ../sprint.tar.xz . && popd >/dev/null
if [ -f ${STAGING_DIR}/sprint} ] ; then chmod -R u+w ${STAGING_DIR}/sprint; fi
rm -rf ${STAGING_DIR}/sprint

cd ${STAGING_DIR_BASE}
if [ "$INSTALL" != "n" ] ; then
    echo "Creating drupal_sprint_package with installs..."
    tar -cf - ${STAGING_DIR_NAME} | gzip -9 >drupal_sprint_package.${QUICKSPRINT_RELEASE}.tar.gz
    zip -9 -r -q drupal_sprint_package.${QUICKSPRINT_RELEASE}.zip ${STAGING_DIR_NAME}
fi
if [ -f ${STAGING_DIR_NAME}/installs ]; then chmod -R u+w ${STAGING_DIR_NAME}/installs; fi
rm -rf ${STAGING_DIR_NAME}/installs
echo "Creating no_extra_installs sprint package..."
tar -cf - ${STAGING_DIR_NAME} | gzip -9 > drupal_sprint_package.no_extra_installs.${QUICKSPRINT_RELEASE}.tar.gz
zip -9 -r -q drupal_sprint_package.no_extra_installs.${QUICKSPRINT_RELEASE}.zip ${STAGING_DIR_NAME}

packages=$(ls ${STAGING_DIR_BASE}/drupal_sprint_package*${QUICKSPRINT_RELEASE}*)
printf "${GREEN}####
# The built sprint tarballs and zipballs are now in ${YELLOW}$STAGING_DIR_BASE${GREEN}:
# ${packages:-}
#
# Package is built, staging directory remains in ${STAGING_DIR}.
####${RESET}\n"
