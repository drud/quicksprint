#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Maximise compression
export XZ_OPT=-9e
export GZIP=-9e

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.
# It assumes it's being run in the repository root.

STAGING_DIR_NAME=drupal_sprint_package
STAGING_DIR_BASE=~/tmp
STAGING_DIR=$STAGING_DIR_BASE/$STAGING_DIR_NAME
REPO_DIR=$PWD
QUICKSPRINT_RELEASE=$(git describe --tags --always --dirty)

# The version lines on the following few lines need to get changed any time the url are changed on the line below.
DOCKER_URLS="https://download.docker.com/mac/stable/23751/Docker.dmg https://download.docker.com/win/stable/16762/Docker%20for%20Windows%20Installer.exe"
DOCKER_VERSION_MAC="18.03.0-ce-mac60"
DOCKER_VERSION_WIN="18.03.0-ce-win59"

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
BINOWNER=$(ls -ld /usr/local/bin | awk '{print $3}')
USER=$(whoami)

# Ensure XZ is installed
command -v xz >/dev/null 2>&1 || { echo >&2 "${RED}I require xz command but it's not installed. Aborting.${RESET}"; exit 1; }
# Check Docker is running
SERVICE='docker'
if ps ax | grep -v grep | grep -v /Library/PrivilegedHelperTools/com.docker.vmnetd | grep $SERVICE > /dev/null
then
    printf "${GREEN}$SERVICE service running, continuing.\n${RESET}"
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi


if [ -d "$STAGING_DIR" ] && [ ! -z "$(ls -A "$STAGING_DIR")" ] ; then
    printf "${RED}The staging directory already has files. Deleting them and recreating everything.${RESET}"
    rm -rf $STAGING_DIR
    if [ -e $STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.tar.gz ] ; then
        rm $STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.tar.gz
    fi
    if [ -e $STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.zip ]; then
        rm $STAGING_DIR_BASE/drupal_sprint_package$QUICKSPRINT_RELEASE.zip
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

printf "
${GREEN}
####
# Shall we package docker installers for mac and windows with the archive?
#### \n${RESET}"

while true; do
    read -p "Include installers? (y/n): " INSTALL
    case $INSTALL in
        [Yy]* ) printf "${GREEN}# Downloading docker installers. \n#### \n${RESET}";
                mkdir -p docker_installs
                for dockerurl in $DOCKER_URLS; do
                    fname=$(basename $dockerurl)
                    if [[ $fname = *"dmg"* ]]; then
                        curl -sSL -o "docker_installs/Docker-$DOCKER_VERSION_MAC.dmg" $dockerurl
                    elif [[ $fname = *"exe"* ]] ; then
                        curl -sSL -o "docker_installs/Docker-$DOCKER_VERSION_WIN.exe" $dockerurl
                    fi
                done
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

# clone or refresh d8 clone
mkdir -p sprint
git clone git://git.drupal.org/project/drupal.git $STAGING_DIR/sprint/drupal8
pushd $STAGING_DIR/sprint/drupal8
cp $REPO_DIR/example.gitignore $STAGING_DIR/sprint/drupal8/.gitignore

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
tar -czf drupal_sprint_package$QUICKSPRINT_RELEASE.tar.gz $STAGING_DIR_NAME
zip -9 -r -q drupal_sprint_package$QUICKSPRINT_RELEASE.zip $STAGING_DIR_NAME
wait

printf "${GREEN}####
# The built sprint tarballs and zipballs are now in ${YELLOW}$STAGING_DIR_BASE${GREEN}.
#
# Now deleting the staging directory.
####${RESET}"
rm -rf $STAGING_DIR_NAME
wait
printf "${GREEN}
# Finished
####${RESET}
"
