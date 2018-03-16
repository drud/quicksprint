#!/bin/bash

# Create archive with docker additions for sprint (IDE and IRC).
docker save -o ${REPO_DIR}/docker_additions.tar briangilbert/cloud9-alpine:latest linuxserver/thelounge:latest
tar cfJ ${STAGING_DIR}/ddev_tarballs/docker_additions.tar.xz ${REPO_DIR}/docker_additions.tar
rm ${REPO_DIR}/docker_additions.tar