#!/bin/bash

set -o errexit

ARTIFACTS=$1
BASE_DIR=$PWD

sudo mkdir $ARTIFACTS && sudo chmod 777 $ARTIFACTS
export VERSION=$(git describe --tags --always --dirty)

cp ~/tmp/drupal_sprint_package* $ARTIFACTS