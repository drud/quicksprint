#!/bin/bash

echo "--- buildkite building at $(date) on $(hostname) for OS=$(go env GOOS) in $PWD with golang=$(go version) docker=$(docker version --format '{{.Server.Version}}') and docker-compose $(docker-compose version --short) ddev version=$(ddev version -j | jq -r .raw.cli)"

set -o errexit
set -o pipefail
set -o nounset

echo "--- package_drupal_script.sh"
rm -f ~/tmp/drupal_sprint_package*gz ~/tmp/drupal_sprint_package*zip
echo "n" | ./package_drupal_script.sh
echo "--- test_drupal_quicksprint.sh"
tests/test_drupal_quicksprint.sh
echo "--- cleanup"
rm -f ~/tmp/drupal_sprint_package.no_docker.$(cat .quicksprint_release.txt).tar.gz
