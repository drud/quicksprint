#!/usr/bin/env bats

# Run these tests from the repo root directory, for example
# bats tests

function setup {
    echo "# setup beginning" >&3
    export SPRINT_BRANCH=8.9.x

    export SPRINTDIR=~/sprint
    # DRUD_NONINTERACTIVE causes ddev not to try to use sudo and add the hostname
    export DRUD_NONINTERACTIVE=true
    # Provide DHOST to figure out the docker host addr for curl
    DHOST=127.0.0.1
    # Extract the IP address we need from DOCKER_HOST, which is formatted like tcp://192.168.99.100:2376
    if [ ! -z "${DOCKER_HOST:-}" ]; then DHOST="$(echo ${DOCKER_HOST} | perl -p -e 's/(tcp:\/\/|:[0-9]+$)//g')"; fi
    cd ${SPRINTDIR} && yes | ./start_sprint.sh
    export SPRINT_NAME=$(cat "${SPRINTDIR}/.test_sprint_name.txt")
    echo "# setup complete" >&3
}

function teardown {
    echo "# teardown beginning" >&3

    ddev delete -O -y ${SPRINT_NAME}
    if [ ! -z "${SPRINTDIR}" -a ! -z "${SPRINT_NAME}" -a -d ${SPRINTDIR}/${SPRINT_NAME} ] ; then
        chmod -R u+w ${SPRINTDIR}/${SPRINT_NAME}
        rm -rf ${SPRINTDIR}/${SPRINT_NAME}
    fi
    echo "# teardown complete" >&3
}

@test "check git configuration" {
    cd ${SPRINTDIR}/${SPRINT_NAME}/drupal8
    [ "$(git config core.eol)" = "lf" ]
    [ "$(git config core.autocrlf)" = "false" ]
    git log -n 1 --pretty=%d HEAD | grep "origin/${SPRINT_BRANCH}"
}

@test "check ddev project status and router status, check http status" {
    cd ${SPRINTDIR}/${SPRINT_NAME}/drupal8
    DESCRIBE=$(ddev describe -j)

    ROUTER_STATUS=$(echo "${DESCRIBE}" | jq -r ".raw.router_status" )
    echo "# Test router status (${ROUTER_STATUS})" >&3
    if [ "$ROUTER_STATUS" != "healthy" ] ; then
        echo "# Router status not healthy (${ROUTER_STATUS})" >&3
        echo "# Full DESCRIBE=${DESCRIBE}" >&3
        ddev list >&3;
        return 101
    fi

    echo "# Testing project status" >&3
    STATUS=$(echo ${DESCRIBE} | jq -r ".raw.status")
    [ "$STATUS" = "running" ]

    echo "# Testing curl reachability for ${NAME}.ddev.site" >&3
    NAME=$(echo ${DESCRIBE} | jq -r ".raw.name")
    HTTP_PORT=$(echo ${DESCRIBE} | jq -r ".raw.router_http_port")
    URL="http://${DHOST}:${HTTP_PORT}"
    CURL="curl -lL -s --fail -H 'Host: ${NAME}.ddev.site' --silent --output /dev/null --url $URL"
    echo "# curl: $CURL" >&3
    ${CURL}

    echo "# Testing switch_branch.sh"
    cd ..
    ./switch_branch.sh 9.0.x
    echo "# Testing curl reachability for ${NAME}.ddev.site" >&3
    echo "# curl: $CURL" >&3
    ${CURL}
}
