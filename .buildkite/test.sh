#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

echo "--- buildkite building at $(date) on $(hostname) for OS=$(go env GOOS) in $PWD"
echo "--- package_drupal_script.sh"
echo "n" | ./package_drupal_script.sh
echo "--- test_drupal_quicksprint.sh"
./test_drupal_quicksprint.sh