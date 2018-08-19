#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

export DDEV_INSTALL_DIR=~/tmp/quicksprint_ddev_tmp
mkdir -p "$DDEV_INSTALL_DIR"
export PATH="$DDEV_INSTALL_DIR:$PATH"

# This should be run from the repo root
export PATH="/usr/local/bin:$PATH"
bats tests

# rm -rf /tmp/drupal_sprint_package

echo "Test successful"
