#!/bin/bash

# This script allows switching drupal branch, for example, from 8.9.x to 9.0.x
# or back

set -o errexit
set -o pipefail
set -o nounset

if [[ $# != 1 ]]; then
  echo "Please provide a branch to switch to. For example 'switch_branch.sh 9.0.x'"
  exit 1
fi


target_branch=$1

pushd drupal8
set -x
ddev start
ddev exec "git stash save && git reset --hard && git checkout origin/${target_branch} && git fetch && git stash apply"
ddev composer require drush/drush:^10
ddev git checkout composer.json composer.lock
ddev composer install
ddev exec drush si --yes standard --account-pass=admin --db-url=mysql://db:db@db/db --site-name=\'Drupal Contribution Time\'
set +x
popd

