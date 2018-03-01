#!/bin/bash
set -e

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.

STAGING_DIR=~/tmp/stuff
DOCKER_URLS="https://download.docker.com/mac/stable/21090/Docker.dmg https://download.docker.com/win/stable/13620/Docker%20for%20Windows%20Installer.exe"
D8DB_URL=https://github.com/drud/quicksprint/raw/master/databases/d8_installed_db.sql.gz

if [ -d "$STAGING_DIR" ] && [ ! -z "$(ls -A \"$STAGING_DIR\")" ] ; then
	echo -n "The staging directory already has files. Do you want to continue (y/n)? "
	read answer
	if echo "$answer" | grep -iq "^y"; then
    	echo "Continuing with downloads, existing files will be respected, mostly."
	else
		exit 1
	fi
fi

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
BINOWNER=$(ls -ld /usr/local/bin | awk '{print $3}')
USER=$(whoami)
SHACMD=""
FILEBASE=""
LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/drud/ddev/releases/latest)
# The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
RELEASE_URL="https://github.com/drud/ddev/releases/download/$LATEST_VERSION"

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

mkdir -p $STAGING_DIR && cd $STAGING_DIR
TARBALL="ddev_docker_images.$LATEST_VERSION.tar.gz"
SHAFILE="$TARBALL.sha256.txt"
if [ ! -f $TARBALL ] ; then
    curl --fail -sSL "$RELEASE_URL/$TARBALL" -o "$TARBALL"
    curl --fail -sSL "$RELEASE_URL/$SHAFILE" -o "$SHAFILE"
fi
$SHACMD -c "$SHAFILE"

# Download the ddev tarball/zipball
for os in macos linux windows; do
    SUFFIX=tar.gz
    if [ $os == "windows" ] ; then
        SUFFIX=zip
    fi
    TARBALL="ddev_$os.$LATEST_VERSION.$SUFFIX"
    SHAFILE="$TARBALL.sha256.txt"

    if [ ! -f $TARBALL ] ; then
        curl --fail -sSL "$RELEASE_URL/$TARBALL" -o "$TARBALL"
        curl --fail -sSL "$RELEASE_URL/$SHAFILE" -o "$SHAFILE"
    fi
    $SHACMD -c "$SHAFILE"
done

# Download current docker installs
for dockerurl in $DOCKER_URLS; do
    fname=$(basename $dockerurl)
    if [ ! -f $fname ] ; then
        curl -sSL -o $fname $dockerurl
    fi
done

# clone or refresh d8 clone
if [ ! -d drupal8/.git ] ; then
    git clone git://git.drupal.org/project/drupal.git drupal8
else
    pushd $STAGING_DIR/drupal8
    git pull
    popd
fi
pushd $STAGING_DIR/drupal8
composer install
ddev config --docroot="" --sitename=drupal8 --apptype=drupal8

# Grab a database for them to install to avoid the install process
mkdir -p .db_dumps
curl --fail -sSL $D8DB_URL -o .db_dumps/$(basename $D8DB_URL)
popd


printf "${GREEN}Stuff has been done.${RESET}\n"
