#!/bin/bash

set -eu

os=$(go env GOOS)

# Upgrade darwin and windows packages
case $os in
darwin)
    brew upgrade mkcert || brew install mkcert || true
    rm /usr/local/bin/ddev && brew unlink ddev && (brew upgrade ddev || brew install ddev || true)
    brew link ddev
    ;;
windows)
    choco upgrade -y mkcert ddev
    ;;
esac
