#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

echo "--- buildkite building at $(date) on $(hostname) for OS=$(go env GOOS) in $PWD"
echo "--- package_drupal_script.sh"
rm -f ~/tmp/drupal_sprint_package*gz ~/tmp/drupal_sprint_package*zip
echo "n" | ./package_drupal_script.sh
echo "--- test_drupal_quicksprint.sh"
tests/test_drupal_quicksprint.sh
echo "--- cleanup"
rm -f ~/tmp/drupal_sprint_package.no_docker.$(cat .quicksprint_release.txt).tar.gz
