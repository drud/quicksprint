#!/bin/bash

# This script allows switching drupal branch, for example, from 9.0.x to 8.9.x
# or back

set -o errexit pipefail nounset

if [[ $# != 1 ]]; then
  echo "Please provide a branch to switch to. For example './switch_branch.sh 8.9.x'"
  exit 1
fi


target_branch=$1

pushd drupal
set -x
ddev start
ddev exec  "git fetch && git stash save && git checkout origin/${target_branch}"
ddev composer install
ddev exec "( git stash apply || true )"
echo "DROP DATABASE db; CREATE DATABASE db; " | ddev mysql -uroot -proot
set +x
popd
echo "Switched to ${target_branch}; you can now install via the web installer"
ddev list
