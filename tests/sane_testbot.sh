#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

echo "sanetestbot.sh: Check to see if test machine has what it needs"

# brew install jq p7zip bats-core composer
# choco install -y jq 7zip composer zip (gd and curl must be enabled in /c/tools/php72/php.ini)
# apt-get install jq p7zip-full
# git clone git://github.com/bats-core/bats-core; cd bats-core; git checkout v1.1.0; sudo ./install.sh /usr/local

for item in curl jq 7z composer perl bats; do
    command -v $item >/dev/null || ( echo "$item is not installed" && exit 2 )
done
docker run --rm -t -v "/$PWD:/junk" busybox ls //junk >/dev/null || ( echo "docker is not running" && exit 3 )

echo "Testbot appears to be sane"
