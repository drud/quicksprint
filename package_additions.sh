#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# Create archive with docker additions for sprint (IDE and IRC).
docker pull briangilbert/cloud9-alpine:20180318 
docker pull linuxserver/thelounge:94
docker save briangilbert/cloud9-alpine:20180318 linuxserver/thelounge:94 | xz -z -9 > $STAGING_DIR/ddev_tarballs/docker_additions.tar.xz
