#!/bin/bash

# This script allows switching drupal branch, for example, from 9.0.x to 8.9.x
# or back

set -o errexit -o pipefail -o nounset

if [[ $# != 1 ]]; then
  echo "Please provide a branch to switch to. For example './switch_branch.sh 9.2.x'"
  exit 1
fi


target_branch=$1

pushd drupal
STASHNAME=switch-branch-${RANDOM}
set -x
ddev start
ddev exec  "git fetch && git stash save ${STASHNAME} && git checkout origin/${target_branch}"
# Silly coder always breaks composer install if there's contents in it, because
# the package uses git instead of a zipball. Temporarily change composer.json to
# ignore, gets turned back by checkout of composer.json below.
ddev composer config discard-changes true
ddev composer install --no-interaction
ddev exec "( git checkout composer.json && (git stash show ${STASHNAME} 2>/dev/null && git stash apply ${STASHNAME} || true) )"
ddev exec drush8 si --yes standard --account-pass=admin --db-url=mysql://db:db@db/db --site-name='Drupal Contribution Time!'
set +x
popd >/dev/null
echo "Switched to ${target_branch}"
ddev list
