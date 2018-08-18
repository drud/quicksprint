#!/bin/bash

# This script creates a new drupal 8 instance in the current directory ready to sprint on an issue.

set -o errexit
set -o pipefail
set -o nounset

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
TIMESTAMP=$(date +"%Y%m%d-%H%M")

# Extract a new ddev D8 core instance to $CWD/sprint-$TIMESTAMP
mkdir -p sprint-${TIMESTAMP}
echo "Untarring sprint.tar.xz"
tar xpf sprint.tar.xz -C sprint-${TIMESTAMP}

#Update ddev project name
perl -pi -e "s/\[ts\]/${TIMESTAMP}/g" sprint-${TIMESTAMP}/*.{txt,sh} sprint-${TIMESTAMP}/.ddev/config.yaml

printf "${GREEN}
######
#
# Your Drupal 8 instance is now ready to use, 
# execute the following commands in terminal 
# to start a Drupal 8 instance to sprint on:
#
# ${YELLOW}cd sprint-${TIMESTAMP}${GREEN}
# ${YELLOW}./start_clean.sh${GREEN}
#
######
${RESET}
"