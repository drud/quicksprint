#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Base checkout should be latest major-minor version branch
SPRINT_BRANCH=9.3.x

# This makes git-bash actually try to create symlinks.
# Use developer mode in Windows 10 so this doesn't require admin privs.
export MSYS=winsymlinks:nativestrict

# Maximise compression
export XZ_OPT=-9e

# This script creates a package of artifacts that can then be used at a contribution event working on Drupal 8.
# It assumes it's being run in the repository root.

STAGING_DIR_NAME=drupal_sprint_package
STAGING_DIR_BASE=~/tmp
STAGING_DIR="$STAGING_DIR_BASE/$STAGING_DIR_NAME"
REPO_DIR=$PWD
QUICKSPRINT_RELEASE=$(git describe --tags --always --dirty)

echo "$QUICKSPRINT_RELEASE" >.quicksprint_release.txt

GIT_TAG_NAME=$(curl -L -s -H 'Accept: application/json' https://github.com/git-for-windows/git/releases/latest | jq -r .tag_name)
GIT_LATEST_RELEASE="$(echo $GIT_TAG_NAME | sed 's/^v//; s/\.windows//')"
GIT_DOWNLOAD_URL="https://github.com/git-for-windows/git/releases/download/${GIT_TAG_NAME}/Git-${GIT_LATEST_RELEASE}-64-bit.exe"
DOWNLOAD_URLS="${GIT_DOWNLOAD_URL}"

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
# Chmod as on Windows read-only stuff is often unremoveable
chmod -R u+w ${STAGING_DIR}/{*.md,install.sh,sprint,start_sprint.sh} 2>/dev/null || true
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
    read -p "Create installer tarball? (y/n): " INSTALL
    case ${INSTALL} in
        [Yy]* ) printf "${GREEN}# Downloading installers. \n#### \n${RESET}";
                mkdir -p installs
                pushd installs >/dev/null
                for download_url in ${DOWNLOAD_URLS}; do
                    echo "Downloading ${download_url##*/} from ${download_url}..."
                    curl -sSL -O ${download_url}
                done
                for arch in amd64 arm64; do
                  echo "Downloading Docker desktop (macOS ${arch})..."
                  curl -sSL -o docker_desktop_${arch}.dmg https://desktop.docker.com/mac/main/${arch}/Docker.dmg
                done
                echo "Downloading Docker desktop (Windows)..."
                curl -sSL -O https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
                popd >/dev/null
                break;;

        [Nn]* ) printf "${GREEN}# Continuing script without downloading installers. \n### \n${RESET}";
                break;;

        * ) echo "Please answer y or n.";;

    esac
done

pushd ${ddev_tarballs} >/dev/null
# Download the ddev tarballs if necessary; check to make sure they all have correct sha256.
for tarball in ddev_macos-amd64.$LATEST_VERSION.tar.gz ddev_macos-arm64.$LATEST_VERSION.tar.gz ddev_linux-amd64.$LATEST_VERSION.tar.gz ddev_linux-arm64.$LATEST_VERSION.tar.gz ddev_windows-amd64.$LATEST_VERSION.tar.gz ddev_windows_installer.$LATEST_VERSION.exe ddev_docker_images.arm64.$LATEST_VERSION.tar.xz ddev_docker_images.amd64.$LATEST_VERSION.tar.xz; do
    shafile="${tarball}.sha256.txt"

    if ! [ -f "${tarball}" -a -f "${shafile}" ] ; then
        echo "Downloading ${tarball} ..."
        curl --fail -sSL "$RELEASE_URL/${tarball}" -o "${tarball}"
        curl --fail -sSL "$RELEASE_URL/$shafile" -o "${shafile}"
    fi
    ${SHACMD} -c "${shafile}"
done
popd >/dev/null

# clone or refresh drupal clone
mkdir -p sprint
git clone --config core.autocrlf=false --config core.eol=lf --config core.filemode=false --quiet https://git.drupalcode.org/project/drupal.git ${STAGING_DIR}/sprint/drupal -b ${SPRINT_BRANCH}
pushd ${STAGING_DIR}/sprint/drupal >/dev/null
cp ${REPO_DIR}/example.gitignore ${STAGING_DIR}/sprint/drupal/.gitignore

set -x
composer install --quiet
set +x

popd >/dev/null

# Copy licenses and COPYING notice.
cp -r ${REPO_DIR}/licenses ${REPO_DIR}/COPYING "$STAGING_DIR/"
cp ${REPO_DIR}/.quicksprint_release.txt $REPO_DIR/.ddev_version.txt "$STAGING_DIR/sprint"

cd ${STAGING_DIR}

echo "Creating sprint.tar.xz..."
# Create tar.xz archive using xz command, so we can work on all platforms
# Use --dereference to NOT use symlinks and not break windows tar.
pushd sprint >/dev/null && tar -cJf ../sprint.tar.xz --dereference . && popd >/dev/null
if [ -f ${STAGING_DIR}/sprint} ] ; then chmod -R u+w ${STAGING_DIR}/sprint; fi
rm -rf ${STAGING_DIR}/sprint

cd ${STAGING_DIR_BASE}
if [ "$INSTALL" != "n" ] ; then
    echo "Creating install tarball..."
    tar -cf - ${STAGING_DIR_NAME}/installs | gzip -9 >quicksprint_thirdparty_installs.${QUICKSPRINT_RELEASE}.tar.gz
    zip -9 -r -q quicksprint_thirdparty_installs.${QUICKSPRINT_RELEASE}.zip ${STAGING_DIR_NAME}/installs
fi
if [ -f ${STAGING_DIR_NAME}/installs ]; then chmod -R u+w ${STAGING_DIR_NAME}/installs; fi
rm -rf ${STAGING_DIR_NAME}/installs
echo "Creating sprint package..."
tar -cf - ${STAGING_DIR_NAME} | gzip -9 > drupal_sprint_package.${QUICKSPRINT_RELEASE}.tar.gz
zip -9 -r -q drupal_sprint_package.${QUICKSPRINT_RELEASE}.zip ${STAGING_DIR_NAME}

packages=$(ls ${STAGING_DIR_BASE}/drupal_sprint_package*${QUICKSPRINT_RELEASE}*)
printf "${GREEN}####
# The built sprint tarballs and optional install tarballs are now in ${YELLOW}$STAGING_DIR_BASE${GREEN}:
# ${packages:-}
#
# Package is built, staging directory remains in ${STAGING_DIR}.
####${RESET}\n"
