#!/usr/bin/env bats

# Run these tests from the repo root directory, for example
# bats tests

function setup {
    export UNTAR_LOCATION=/tmp
    export SOURCE_TARBALL_LOCATION=~/tmp/drupal_sprint_package.no_docker.$(cat .quicksprint_release.txt).tar.gz
    export SPRINTDIR=~/Sites/sprint
}

# brew install jq bats-core
@test "check for prereqs (docker etc)" {
    run command -v curl
    [ "$status" -eq 0 ]
    run command -v jq
    [ "$status" -eq 0 ]
    run docker run -t -v "$HOME:/tmp/home" -p 80:8088 busybox ls
    [ "$status" -eq 0 ]
}


@test "untar and run drupal_sprint_package" {
#    echo "# rm -rf $UNTAR_LOCATION/drupal_sprint_package" >&3
    run rm -rf "$UNTAR_LOCATION/drupal_sprint_package"
    [ "$status" -eq 0 ]

#    echo "# tar -C $UNTAR_LOCATION -zxf $SOURCE_TARBALL_LOCATION" >&3
    run tar -C "$UNTAR_LOCATION" -zxf "$SOURCE_TARBALL_LOCATION"
    [ "$status" -eq 0 ]

    run bash -c "chmod -R ugo+w $SPRINTDIR/sprint-2* && rm -rf $SPRINTDIR/sprint-2*"
    # Don't check the result of this one as it's not very important; not important if it's not there.
}

@test "install_ddev.sh - and Sprint directories" {
    run bash -c "cd $UNTAR_LOCATION/drupal_sprint_package && printf 'y\ny\n' | ./install_ddev.sh"
    echo "# status=$status lines=$lines" >&3
    if [ "$status" -ne 0 ]; then
        echo "# ERROR: status=$status lines=$lines" 3>&1
    fi
}

@test "make sure no ddev projects are running" {
    run ddev rm -a
}

@test "run start_sprint.sh" {
    run bash -c "cd $SPRINTDIR && ./start_sprint.sh"
    if [ "$status" -ne 0 ]; then
        echo "# ERROR: status=$status lines=$lines" 3>&1
        return 1
    fi
    echo "# SPRINTDIR CONTENTS=$(ls $SPRINTDIR)" 3>&1
}

@test "run start_clean.sh" {
    # Run start_clean.sh in the (only) sprint directory
    run bash -c "ls $SPRINTDIR && cd $SPRINTDIR/sprint-2* && echo y | ./start_clean.sh"
    if [ "$status" -ne 0 ] ; then
        echo "# ERROR: status=$status lines=$lines SPRINTDIR CONTENTS=$(ls $SPRINTDIR)" 3>&1
        return 1
    fi
}

@test "check ddev site status" {
    run bash -c "cd $SPRINTDIR/sprint-2* && ddev describe -j | jq -r .raw.router_status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "healthy" ]

    run bash -c "cd $SPRINTDIR/sprint-2* && ddev describe -j | jq -r .raw.status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "running" ]
}

@test "check http status of project for 200" {
    run curl --write-out %{http_code} --silent --output /dev/null $(bash -c "cd $SPRINTDIR/sprint-2* && ddev describe -j | jq -r .raw.httpurl")
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "200" ]
}