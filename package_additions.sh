#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Create archive with docker additions for sprint (IDE).
docker pull briangilbert/cloud9-alpine:20180318
printf "${GREEN}#####
# Compressing image/s.
# This can take a while.
#####${RESET}"
docker save briangilbert/cloud9-alpine:20180318 | xz -z -9e > $STAGING_DIR/ddev_tarballs/docker_additions.tar.xz
