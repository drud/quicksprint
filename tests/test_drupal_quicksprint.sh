#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# This test script should be run from the repo root
UNTAR_LOCATION=/tmp
export SPRINTDIR=~/sprint
export QUICKSPRINT_RELEASE=$(cat .quicksprint_release.txt)
export DDEV_INSTALL_DIR=~/tmp/quicksprintbin

# Add /usr/local/bin to path for git-bash, where it may not exist.
export PATH="$PATH:/usr/local/bin"

tests/sane_testbot.sh || ( echo "sane_testbot.sh failed, test machine is not ready for duty" && exit 1 )

# Clean up any previous existing stuff
(chmod -R ugo+w "$SPRINTDIR/" && rm -rf  ${SPRINTDIR}/sprint-2* ) || true
rm -rf "$UNTAR_LOCATION/drupal_sprint_package"

echo n | ./package_drupal_script.sh || ( echo "package_drupal_script.sh failed" && exit 2 )
# SOURCE_TARBALL_LOCATION isn't valid until package_drupal_script has run.
SOURCE_TARBALL_LOCATION=~/tmp/drupal_sprint_package.no_docker.${QUICKSPRINT_RELEASE}.tar.gz

# Untar source tarball
tar -C "$UNTAR_LOCATION" -zxf "$SOURCE_TARBALL_LOCATION"

# Run install_ddev.sh
(cd "${UNTAR_LOCATION}/drupal_sprint_package" && printf 'y\ny\n' | ./install_ddev.sh) || ( echo "Failed to install_ddev.sh" && exit 3 )

# Stop any running ddev instances, if we can
ddev rm -a

# /usr/local/bin is added for git-bash, where it may not be in the $PATH.
export PATH="/usr/local/bin:$PATH"
bats tests || ( echo "bats tests failed" && exit 4 )

# rm -rf /tmp/drupal_sprint_package
rm "${SOURCE_TARBALL_LOCATION}"

echo "Test successful"
