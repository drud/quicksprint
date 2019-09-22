#!/bin/bash

echo "--- buildkite building at $(date) on $(hostname) for OS=$(go env GOOS) in $PWD with golang=$(go version) docker=$(docker version --format '{{.Server.Version}}') and docker-compose $(docker-compose version --short) ddev version=$(ddev --version)"

set -o errexit
set -o pipefail
set -o nounset
export DDEV_NO_INSTRUMENTATION=true

# Run any testbot maintenance that may need to be done
echo "--- running testbot_maintenance.sh"
bash $(dirname $0)/testbot_maintenance.sh

echo "--- package_drupal_script.sh"
rm -f ~/tmp/drupal_sprint_package*gz ~/tmp/drupal_sprint_package*zip
echo "n" | ./package_drupal_script.sh
echo "--- test_drupal_quicksprint.sh"
tests/test_drupal_quicksprint.sh
echo "--- cleanup"
rm -f ~/tmp/*$(cat .quicksprint_release.txt)*.tar.gz
