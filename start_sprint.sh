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
SPRINTNAME="sprint-${TIMESTAMP}"

# Extract a new ddev D8 core instance to $CWD/sprint-$TIMESTAMP
mkdir -p ${SPRINTNAME}
echo "Untarring sprint.tar.xz" >&2
tar -xpf sprint.tar.xz -C ${SPRINTNAME}

#Update ddev project name
perl -pi -e "s/\[ts\]/${TIMESTAMP}/g" ${SPRINTNAME}/*.{txt,sh} ${SPRINTNAME}/.ddev/config.yaml
rm -f ${SPRINTNAME}/*.bak

# Next line is (only) stdout output, lets caller know the name of the project created
printf ${SPRINTNAME}

# And this goes to stderr
printf "${GREEN}
######
#
# Your Drupal 8 instance is now ready to use, 
# execute the following commands in terminal 
# to start a Drupal 8 instance to sprint on:
#
# ${YELLOW}cd ${SPRINTNAME}${GREEN}
# ${YELLOW}./start_clean.sh${GREEN}
#
######
${RESET}
" >&2
