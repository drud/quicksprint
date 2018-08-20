#!/usr/bin/env bats

# Run these tests from the repo root directory, for example
# bats tests

function setup {
    echo "# setup beginning" >&3
    export SPRINTDIR=~/sprint
    # DRUD_NONINTERACTIVE causes ddev not to try to use sudo and add the hostname
    export DRUD_NONINTERACTIVE=true
    # Provide DHOST to figure out the docker host addr for curl
    DHOST=127.0.0.1
    # Extract the IP address we need from DOCKER_HOST, which is formatted like tcp://192.168.99.100:2376
    if [ ! -z "${DOCKER_HOST:-}" ]; then DHOST="$(echo ${DOCKER_HOST} | perl -p -e 's/(tcp:\/\/|:[0-9]+$)//g')"; fi

    cd ${SPRINTDIR} && export SPRINT_NAME=$(./start_sprint.sh)
    cd ${SPRINTDIR}/${SPRINT_NAME} && echo y | ./start_clean.sh
    echo "# setup complete" >&3
}

function teardown {
    echo "# teardown beginning" >&3

    ddev rm -R --omit-snapshot ${SPRINT_NAME}
    if [ ! -z "${SPRINTDIR}" -a ! -z "${SPRINT_NAME}" -a -d ${SPRINTDIR}/${SPRINT_NAME} ] ; then
        rm -rf ${SPRINTDIR}/${SPRINT_NAME}
    fi
    echo "# teardown complete" >&3
}

@test "check ddev project status and router status, check http status" {
    DESCRIBE=$(cd ${SPRINTDIR}/${SPRINT_NAME} && ddev describe -j)

    echo "# Testing router status" >&3
    ROUTER_STATUS=$(echo ${DESCRIBE} | jq -r ".raw.router_status" )
    [ "$ROUTER_STATUS" = "healthy" ]

    echo "# Testing project status" >&3
    STATUS=$(echo ${DESCRIBE} | jq -r ".raw.status")
    [ "$STATUS" = "running" ]

    echo "# Testing curl reachability" >&3
    NAME=$(echo ${DESCRIBE} | jq -r ".raw.name")
    HTTP_PORT=$(echo ${DESCRIBE} | jq -r ".raw.router_http_port")
    URL="http://${DHOST}:${HTTP_PORT}"
    CURL="curl --fail -H 'Host: ${NAME}.ddev.local' --silent --output /dev/null --url $URL"
    echo "# curl: $CURL" >&3
    ${CURL}
}