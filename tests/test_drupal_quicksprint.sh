#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# This test script should be run from the repo root
UNTAR_LOCATION=/tmp
UNTARRED_PACKAGE=$UNTAR_LOCATION/drupal_sprint_package
export SPRINTDIR=~/sprint
export QUICKSPRINT_RELEASE=$(cat .quicksprint_release.txt)

# For testing, use a custom version of ddev, ignore one that might otherwise be in path.
export DDEV_INSTALL_DIR=~/tmp/quicksprint_ddev_tmp
mkdir -p "$DDEV_INSTALL_DIR"
export PATH="$DDEV_INSTALL_DIR:$PATH"

# Add /usr/local/bin to path for git-bash, where it may not exist.
export PATH="$PATH:/usr/local/bin"

tests/sanetestbot.sh || ( echo "sanetestbot.sh failed, test machine is not ready for duty" && exit 1 )

function cleanup {
    rm -rf /tmp/drupal_sprint_package
    if [ ! -z "${SOURCE_TARBALL_LOCATION:-}" ] ; then rm -f ${SOURCE_TARBALL_LOCATION:-nopedontrm}; fi
}
trap cleanup EXIT


# Clean up any previous existing stuff
(mkdir -p ${SPRINTDIR} && chmod -R ugo+w "$SPRINTDIR/" && rm -rf  ${SPRINTDIR}/sprint-2* ) || true
rm -rf "$UNTARRED_PACKAGE"

echo n | ./package_drupal_script.sh || ( echo "package_drupal_script.sh failed" && exit 2 )
# SOURCE_TARBALL_LOCATION isn't valid until package_drupal_script has run.
SOURCE_TARBALL_LOCATION=~/tmp/drupal_sprint_package.no_extra_installs.${QUICKSPRINT_RELEASE}.tar.gz

# Untar source tarball
tar -C "$UNTAR_LOCATION" -zxf ${SOURCE_TARBALL_LOCATION:-}

if [ ! -f "$UNTARRED_PACKAGE/DRUPAL_SPRINTUSER_README.md" -o ! -f "$UNTARRED_PACKAGE/COPYING" -o ! -d "$UNTARRED_PACKAGE/licenses" ]; then
    echo "Packaged documents are missing from sprint package (in $UNTARRED_PACKAGE)"
    exit 3
fi

# Run install.sh
(cd "$UNTARRED_PACKAGE" && printf 'y\ny\n' | ./install.sh) || ( echo "Failed to install.sh" && exit 4 )

# Stop any running ddev instances, if we can
ddev rm -a

# /usr/local/bin is added for git-bash, where it may not be in the $PATH.
export PATH="/usr/local/bin:$PATH"
bats tests || ( echo "bats tests failed" && exit 5 )

echo "Test successful"
