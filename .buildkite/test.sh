#!/bin/bash

echo "--- buildkite building at $(date) on $(hostname) for OS=$(go env GOOS) in $PWD with golang=$(go version) docker=$(docker version --format '{{.Server.Version}}') and docker-compose $(docker-compose version --short) ddev version=$(ddev version -j | jq -r .raw.cli)"

set -o errexit
set -o pipefail
set -o nounset

echo "--- package.sh"
rm -f ~/tmp/drupal_sprint_package*gz ~/tmp/drupal_sprint_package*zip
echo "n" | ./package.sh
echo "--- test_drupal_quicksprint.sh"
tests/test_drupal_quicksprint.sh
echo "--- cleanup"
rm -f ~/tmp/drupal_sprint_package.no_extra_installs.*$(cat .quicksprint_release.txt)*.tar.gz
