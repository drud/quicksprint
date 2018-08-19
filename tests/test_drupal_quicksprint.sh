#!/bin/bash

#set -o errexit
set -o pipefail
set -o nounset

# This should be run from the repo root

if ! tests/sanetestbot.sh ; then

export PATH="/usr/local/bin:$PATH"
bats tests

# rm -rf /tmp/drupal_sprint_package

echo "Test successful"
