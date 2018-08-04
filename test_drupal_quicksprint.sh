#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Initial setup: Make sure we have no ddev
if which ddev; then
  echo "ddev is already on this system"
  exit 1
fi

# Untar the sprint package (no docker version should be fine)
tar -C /tmp -zxf ~/tmp/drupal_sprint_package.no_docker.$(cat ./.quicksprint_release.txt).tar.gz
# Run the standard install_ddev.sh, asserting we already have docker set up.
cd /tmp/drupal_sprint_package && echo y | ./install_ddev.sh


# Remove any existing sprints, then do start_sprint.sh
cd ~/Sites/sprint
find ~/Sites/sprint -type d -name "sprint-2*" -exec chmod -R u+w '{}' \; -exec rm -rf '{}' \;
echo y | ./start_sprint.sh

# Run start_sprint in the (only) sprint directory
cd ~/Sites/sprint/sprint-2* && echo y | ./start_clean.sh

# Confirms web and router status.
ddev describe | grep -q running || exit 1
ddev describe | grep -q "DDEV ROUTER STATUS: healthy" || exit 1

# Confirms site is responding with 200.
SITE_URL=`ddev describe | grep -o -m 1 "https://sprint-[0-9\-]\+\.ddev\.local"`
curl -k -L -I --silent ${SITE_URL}:8443 | head -n 1 | grep -q 200 || echo "ERROR: Could not connect to ${SITE_URL}:8443!"; exit 1

rm -r /tmp/drupal_sprint_package

echo "Test successful"
