#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

bats tests

# rm -r /tmp/drupal_sprint_package

echo "Test successful"
