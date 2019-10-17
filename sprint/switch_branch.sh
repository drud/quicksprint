#!/bin/bash

# This script allows switching drupal branch, for example, from 9.0.x to 8.9.x
# or back

set -o errexit
set -o pipefail
set -o nounset

if [[ $# != 1 ]]; then
  echo "Please provide a branch to switch to. For example 'switch_branch.sh 8.9.x'"
  exit 1
fi


target_branch=$1

pushd drupal8
set -x
ddev start
ddev exec "git stash save"
ddev exec "git reset --hard && git fetch && git checkout origin/${target_branch} "
ddev composer install
if [ "${target_branch}" '>' "9." ]; then ddev composer require drush/drush:^10; fi
# Make sure that composer.json/lock don't show up in patches
ddev exec "git checkout /var/www/html/composer.*"
ddev exec "git stash apply || true"
ddev exec drush si --yes standard --account-pass=admin --db-url=mysql://db:db@db/db --site-name=\'Drupal Contribution Time\'
set +x
popd
echo "Switched to ${target_branch}"
