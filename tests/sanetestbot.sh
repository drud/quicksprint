#!/bin/bash

MIN_DDEV_VERSION=v1.5

set -o errexit
set -o pipefail
set -o nounset

echo "sanetestbot.sh: Check to see if test machine has what it needs"

# brew install jq xz bats-core composer
# choco install -y jq composer zip (gd and curl must be enabled in /c/tools/php72/php.ini)
 # git clone git://github.com/bats-core/bats-core; cd bats-core; git checkout v1.1.0; sudo ./install.sh /usr/local

DISK_AVAIL=$(df -k . | awk '/[0-9]%/ { gsub(/%/, ""); print $5}')
if [ ${DISK_AVAIL} -ge 95 ] ; then
    echo "Disk usage is ${DISK_AVAIL}% on $(hostname), not usable";
    exit 1;
fi

for item in curl jq zcat composer perl zip bats; do
    command -v $item >/dev/null || ( echo "$item is not installed" && exit 2 )
done

DOCKER_CMD="docker run --rm -t -v "/$PWD:/junk" busybox ls //junk "
# Try the docker run command twice because of the really annoying mkdir /c: file exists bug
# Apparently https://github.com/docker/for-win/issues/1560
(sleep 1 && ( $DOCKER_CMD >/dev/null ) || (sleep 1 && $DOCKER_CMD >/dev/null )) || ( echo "docker is not running or can't do `$DOCKER_CMD`" && exit 3 )

if command -v ddev >/dev/null && [ "$(ddev version -j | jq -r .raw.cli)" \< "${MIN_DDEV_VERSION}" ] ; then
  echo "ddev version in $(command -v ddev) is inadequate: $(ddev version -j | jq -r .raw.cli)"
  exit 4
fi

echo "Testbot appears to be sane"
