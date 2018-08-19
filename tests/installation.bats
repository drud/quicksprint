#!/usr/bin/env bats

# Run these tests from the repo root directory, for example
# bats tests

function setup {
    export SPRINTDIR=~/sprint
    # DRUD_NONINTERACTIVE causes ddev not to try to use sudo and add the hostname
    export DRUD_NONINTERACTIVE=true
    # Provide DHOST to figure out the docker host addr for curl
    DHOST=127.0.0.1
    # Extract the IP address we need from DOCKER_HOST, which is formatted like tcp://192.168.99.100:2376
    if [ ! -z "${DOCKER_HOST:-}" ]; then DHOST="$(echo ${DOCKER_HOST} | perl -p -e 's/(tcp:\/\/|:[0-9]+$)//g')"; fi

    cd ${SPRINTDIR} && export SPRINT_NAME=$(./start_sprint.sh)
    cd ${SPRINTDIR}/${SPRINT_NAME} && echo y | ./start_clean.sh
}

function teardown {
    ddev rm -R --omit-snapshot ${SPRINT_NAME}
    if [ ! -z "${SPRINTDIR}" -a ! -z "${SPRINT_NAME}" -a -d ${SPRINTDIR}/${SPRINT_NAME} ] ; then
        rm -rf ${SPRINTDIR}/${SPRINT_NAME};
    fi
}

@test "check ddev project status and router status, check http status" {

    [ -f ${SPRINTDIR}/SPRINTUSER_README.md -a -f ${SPRINTDIR}/COPYING -a -d ${SPRINTDIR}/licenses ]
    DESCRIBE=$(cd ${SPRINTDIR}/${SPRINT_NAME} && ddev describe -j)
    ROUTER_STATUS=$(echo ${DESCRIBE} | jq -r ".raw.router_status" )
    [ "$ROUTER_STATUS" = "healthy" ]

    STATUS=$(echo ${DESCRIBE} | jq -r ".raw.status")
    [ "$STATUS" = "running" ]

    DESCRIBE=$(cd ${SPRINTDIR}/${SPRINT_NAME} && ddev describe -j)
    NAME=$(echo ${DESCRIBE} | jq -r ".raw.name")
    HTTP_PORT=$(echo ${DESCRIBE} | jq -r ".raw.router_http_port")
    URL="http://${DHOST}:${HTTP_PORT}"
    CURL="curl --fail -H 'Host: ${NAME}.ddev.local' --silent --output /dev/null --url $URL"
    echo "# curl: $CURL" >&3
    ${CURL}
}
