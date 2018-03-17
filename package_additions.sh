#!/bin/bash

# Create archive with docker additions for sprint (IDE and IRC).
docker save briangilbert/cloud9-alpine:latest linuxserver/thelounge:latest | xz -z -9 > ${REPO_DIR}/docker_additions.tar.xz
