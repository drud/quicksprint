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
git clone --config core.autocrlf=false --config core.eol=lf --quiet https://git.drupal.org/project/drupal.git ${STAGING_DIR}/sprint/drupal8 -b ${SPRINT_BRANCH}
pushd ${STAGING_DIR}/sprint/drupal8 >/dev/null
cp ${REPO_DIR}/example.gitignore ${STAGING_DIR}/sprint/drupal8/.gitignore

echo "Running composer install --quiet"
composer install --quiet
popd >/dev/null

cd ${STAGING_DIR}

printf "
${GREEN}
####
# Package Cloud9 IDE image?
#   This increases the size of the package and requires more memory, but
#   gives users an IDE without needing to install one as well as PHP
#   or NodeJS locally.
#### \n${RESET}"

while true; do
    read -p "Include Cloud9 IDE? (y/n): " CLOUD9
    case ${CLOUD9} in
        [Yy]* ) printf "${GREEN}# Downloading briangilbert/cloud9-alpine. \n#### \n${RESET}";
                docker pull briangilbert/cloud9-alpine:20180318
                cp "${REPO_DIR}/framework/drupal/docker-compose.ide.yml" "${STAGING_DIR}/sprint/.ddev/"
                printf "${GREEN}#### \n# Compressing image. \n#This may take a while. \n####\n${RESET}";
                docker save briangilbert/cloud9-alpine:20180318 | xz -z ${XZ_OPT} > $STAGING_DIR/ddev_tarballs/docker_additions.tar.xz
                break;;

        [Nn]* ) printf "${GREEN}#### \n# Continuing script without including Cloud9 IDE. \n#### \n${RESET}";
                break;;

        * ) echo "Please answer y or n.";;
    esac
done

cp ${REPO_DIR}/framework/drupal/SPRINTUSER_README.md ${STAGING_DIR}

exit 0

