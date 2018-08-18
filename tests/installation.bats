#!/usr/bin/env bats

# Run these tests from the repo root directory, for example
# bats tests

function setup {
    export UNTAR_LOCATION=/tmp
    export SOURCE_TARBALL_LOCATION=~/tmp/drupal_sprint_package.no_docker.$(cat .quicksprint_release.txt).tar.gz
    export SPRINTDIR=~/sprint
    # DRUD_NONINTERACTIVE causes ddev not to try to use sudo and add the hostname
    export DRUD_NONINTERACTIVE=true
    # Provide DHOST to figure out the docker host addr for curl
    DHOST=127.0.0.1
    if [ ! -z "$DOCKER_HOST" ]; then DHOST=$DOCKER_HOST; fi
}

# brew install jq p7zip bats-core composer
# choco install -y jq 7zip composer zip (gd and curl must be enabled in /c/tools/php72/php.ini)
# apt-get install jq p7zip-full
# git clone git://github.com/bats-core/bats-core; cd bats-core; git checkout v1.1.0; sudo ./install.sh /usr/local
# Passwordless sudo required.
# Developer mode enabled.
@test "check for prereqs (docker etc)" {
    command -v curl
    command -v jq
    command -v 7z
    command -v composer
    command -v perl
    #  passwordless sudo ought to be available, but this command doesn't work on windows.
    # echo junk | sudo -S ls
    docker run -t -v "$PWD:/tmp/pwd" -p 80:8088 busybox ls >/dev/null
    cd /tmp && touch junk.txt && ln -s junk.txt junk.txt.link
    # Make sure that we have symlink creation capability (Windows 10, developer mode enabled)
    [ -L junk.txt.link ]
}


@test "untar and run drupal_sprint_package" {
    rm -rf "$UNTAR_LOCATION/drupal_sprint_package"
    echo "# UNTAR_LOCATION=$UNTAR_LOCATION SOURCE_TARBALL_LOCATION=$SOURCE_TARBALL_LOCATION" >&3
    tar -C "$UNTAR_LOCATION" -zxf "$SOURCE_TARBALL_LOCATION"
    chmod -R ugo+w "$SPRINTDIR/" && rm -rf $SPRINTDIR/sprint-2* || true
}

@test "install_ddev.sh - and Sprint directories" {
    cd $UNTAR_LOCATION/drupal_sprint_package && printf 'y\ny\n' | bash -x ./install_ddev.sh
}

@test "rm any ddev projects" {
    ddev rm -a
}

@test "run start_sprint.sh" {
    cd $SPRINTDIR && bash -x ./start_sprint.sh
}

@test "run start_clean.sh" {
    # Run start_clean.sh in the (only) sprint directory
    cd $SPRINTDIR/sprint-2* && echo y | ./start_clean.sh
}

@test "check ddev project status and router status" {
    DESCRIBE=$(cd $SPRINTDIR/sprint-2* && ddev describe -j)
    ROUTER_STATUS=$(echo $DESCRIBE | jq -r ".raw.router_status" )
    [ "$ROUTER_STATUS" = "healthy" ]

    STATUS=$(echo $DESCRIBE | jq -r ".raw.status")
    [ "$STATUS" = "running" ]
}

@test "check http status of project for 200" {
    DESCRIBE=$(cd $SPRINTDIR/sprint-2* && ddev describe -j)
    NAME=$(echo $DESCRIBE | jq -r ".raw.name")
    HTTP_PORT=$(echo $DESCRIBE | jq -r ".raw.router_http_port")
    URL="http://${DHOST}:${HTTP_PORT}"
    CURL="curl --fail -H 'Host: ${NAME}.ddev.local' --silent --output /dev/null --url $URL"
    echo "# curl: $CURL" >&3
    $CURL
}