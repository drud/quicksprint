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
ddev exec "git stash && git reset --hard && git checkout ${target_branch} && git pull && git stash pop"
ddev composer require drush/drush:^10
ddev composer install
ddev exec drush si --yes standard --account-pass=admin --db-url=mysql://db:db@db/db --site-name='Drupal Contribution Time
'
set +x
popd

