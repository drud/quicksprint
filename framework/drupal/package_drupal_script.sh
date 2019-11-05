#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Base checkout should be of the 8.7.x branch
SPRINT_BRANCH=8.7.x

# Maximise compression
export XZ_OPT=-9e

# This script creates a package of artifacts that can then be used at a code sprint working on Drupal 8.

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
USER=$(whoami)

cd ${STAGING_DIR}

printf "${GREEN}####\n# Preparing Drupal codebase...\n#### \n${RESET}"

# clone or refresh d8 clone
mkdir -p sprint
git clone --config core.autocrlf=false --config core.eol=lf --config core.filemode=false --quiet https://git.drupal.org/project/drupal.git ${STAGING_DIR}/sprint/drupal8 -b ${SPRINT_BRANCH}
pushd ${STAGING_DIR}/sprint/drupal8 >/dev/null
cp ${REPO_DIR}/example.gitignore ${STAGING_DIR}/sprint/drupal8/.gitignore

set -x
composer install --quiet
set +x

# The next line is a temporary workaround prevents the failures described in
# https://github.com/drud/quicksprint/issues/151 and
# https://www.drupal.org/project/drupal/issues/3082866
# It should be resolved when the upstream drupal issue is resolved.
# But in the meantime the `composer install` is done over again during
# sprint startup. rfay 20190926
rm -f vendor/bin/composer vendor/composer/composer/bin/composer

popd >/dev/null

cd ${STAGING_DIR}

# @todo Optionally build package with Cloud 9 IDE.

# Copies framework-specific files to the staging directory.
cp ${REPO_DIR}/framework/drupal/start_sprint.sh ${STAGING_DIR}
cp ${REPO_DIR}/framework/drupal/SPRINTUSER_README.md ${STAGING_DIR}
cp ${REPO_DIR}/framework/drupal/sprint_readme.txt ${STAGING_DIR}/sprint/Readme.txt
cp ${REPO_DIR}/framework/drupal/switch_branch.sh ${STAGING_DIR}/sprint/switch_branch.sh

exit 0

