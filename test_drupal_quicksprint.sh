#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# This should be run from the repo root
echo "PATH=$PATH"
/usr/local/bin/bats tests

# rm -rf /tmp/drupal_sprint_package

echo "Test successful"
