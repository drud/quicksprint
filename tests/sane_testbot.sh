#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

echo "sanetestbot.sh: Check to see if testbot has what it needs"

for item in curl jq 7z composer perl bats; do
    command -v $item >/dev/null || ( echo "$item is not installed" && exit 2 )
done
docker run --rm -t -v "/$PWD:/junk" busybox ls //junk >/dev/null || ( echo "docker is not running" && exit 3 )

echo "Testbot appears to be sane"
