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

rm -r /tmp/drupal_sprint_package

echo "Test successful"
