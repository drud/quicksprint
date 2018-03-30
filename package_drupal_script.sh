#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.
# It assumes it's being run in teh repository root.

STAGING_DIR_NAME=drupal_sprint_package
STAGING_DIR_BASE=~/tmp
STAGING_DIR=$STAGING_DIR_BASE/$STAGING_DIR_NAME
REPO_DIR=$PWD

DOCKER_URLS="https://download.docker.com/mac/stable/23608/Docker.dmg https://download.docker.com/win/stable/16762/Docker%20for%20Windows%20Installer.exe"

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
BINOWNER=$(ls -ld /usr/local/bin | awk '{print $3}')
USER=$(whoami)

if [ -d "$STAGING_DIR" ] && [ ! -z "$(ls -A "$STAGING_DIR")" ] ; then
    echo -n "The staging directory already has files. Do you want to continue (y/n)? "
    read answer
    if echo "$answer" | grep -iq "^y"; then
        echo "Continuing with downloads, existing files will be respected, mostly."
    else
        exit 1
    fi
fi

SHACMD=""
FILEBASE=""
LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/drud/ddev/releases/latest)
# The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
RELEASE_URL="https://github.com/drud/ddev/releases/download/$LATEST_VERSION"

echo "$LATEST_VERSION" >.latest_version.txt

# Install the beginning items we need in the kit.
mkdir -p $STAGING_DIR
cp -r .latest_version.txt bin sprint start_sprint.* SPRINTUSER_README.md install_ddev.* $STAGING_DIR


if [[ "$OS" == "Darwin" ]]; then
    SHACMD="shasum -a 256"
    FILEBASE="ddev_macos"
elif [[ "$OS" == "Linux" ]]; then
    SHACMD="sha256sum"
    FILEBASE="ddev_linux"
else
    printf "${RED}Sorry, this packager only works on macOS and Linux currently.${RESET}\n"
    exit 1
fi

if ! docker --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker is required to use this package. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
fi

cd $STAGING_DIR
mkdir -p ddev_tarballs
TARBALL="ddev_docker_images.$LATEST_VERSION.tar.xz"
SHAFILE="$TARBALL.sha256.txt"
if [ ! -f "ddev_tarballs/$TARBALL" ] ; then
    curl --fail -sSL "$RELEASE_URL/$TARBALL" -o "ddev_tarballs/$TARBALL"
    curl --fail -sSL "$RELEASE_URL/$SHAFILE" -o "ddev_tarballs/$SHAFILE"
fi
pushd ddev_tarballs
$SHACMD -c "$SHAFILE"
popd

# Download the ddev tarball/zipball
for os in macos linux windows; do
    pwd
    SUFFIX=tar.gz
    if [ $os == "windows" ] ; then
        SUFFIX=zip
    fi
    TARBALL="ddev_$os.$LATEST_VERSION.$SUFFIX"
    SHAFILE="$TARBALL.sha256.txt"

    if [ ! -f "ddev_tarballs/$TARBALL" ] ; then
        curl --fail -sSL "$RELEASE_URL/$TARBALL" -o "ddev_tarballs/$TARBALL"
        curl --fail -sSL "$RELEASE_URL/$SHAFILE" -o "ddev_tarballs/$SHAFILE"
    fi
    pushd ddev_tarballs
    $SHACMD -c $(basename "$SHAFILE")
    popd
done

# Download current docker installs
mkdir -p docker_installs
for dockerurl in $DOCKER_URLS; do
    fname=$(basename $dockerurl)
    if [ ! -f "docker_installs/$fname" ] ; then
        curl -sSL -o "docker_installs/$fname" $dockerurl
    fi
done

# clone or refresh d8 clone
mkdir -p sprint
if [ ! -d sprint.tar.xz ] ; then
    git clone git://git.drupal.org/project/drupal.git $STAGING_DIR/sprint/drupal8
else
    pushd $STAGING_DIR
    tar xpvf sprint.tar.xz -C sprint
    rm sprint.tar.xz
    cd $STAGING_DIR/sprint/drupal8
    git pull
    popd
fi
pushd $STAGING_DIR/sprint/drupal8
composer install

# Copy licenses and COPYING notice.
cp -r $REPO_DIR/licenses $STAGING_DIR/
cp $REPO_DIR/COPYING $STAGING_DIR/
popd

cd $STAGING_DIR
tar cfJ sprint.tar.xz -C sprint .
rm -rf $STAGING_DIR/sprint

if [ -f ${REPO_DIR}/package_additions.sh ]; then
    # Package images for any additions.
    source ${REPO_DIR}/package_additions.sh
fi

cd $STAGING_DIR_BASE
tar -czf drupal_sprint_package.tar.gz $STAGING_DIR_NAME
zip -r -q drupal_sprint_package.zip $STAGING_DIR_NAME
wait
printf "${GREEN}The sprint tarballs and zipballs are in $(ls $STAGING_DIR_BASE/drupal_sprint_package*).${RESET}\n"
