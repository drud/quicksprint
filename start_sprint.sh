#!/bin/bash

# This script creates a new drupal instance in the current directory.

set -o errexit
set -o pipefail
set -o nounset

SPRINT_BRANCH=9.3.x

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
TIMESTAMP=$(date +"%Y%m%d-%H%M")
SPRINTNAME="sprint-${TIMESTAMP}"
echo ${SPRINTNAME} > .test_sprint_name.txt

# Extract a new ddev D9 core instance to $CWD/sprint-$TIMESTAMP
mkdir -p ${SPRINTNAME}
echo "Untarring sprint.tar.xz" >&2
tar -xpf sprint.tar.xz -C ${SPRINTNAME}

# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
then
    printf "docker is running, continuing."
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

cd "${SPRINTNAME}/drupal"
echo "Using ddev version $(ddev version| awk '/^cli/ { print $2}') from $(which ddev)"

ddev config --docroot . --project-type drupal9 --php-version=7.4 --composer-version=2 --mariadb-version=10.3 --http-port=8080 --https-port=8443 --project-name="sprint-${TIMESTAMP}"

ddev config global --instrumentation-opt-in=false >/dev/null
printf "${YELLOW}Configuring your fresh Drupal instance. This takes a few minutes.${RESET}\n"
printf "${YELLOW}Running ddev start...YOU MAY BE ASKED for your sudo password to add a hostname to /etc/hosts${RESET}\n"
ddev start || (printf "${RED}ddev start failed.${RESET}" && exit 101)
printf "${YELLOW}Running git fetch && git checkout origin/${SPRINT_BRANCH}.${RESET}...\n"
ddev exec "(git fetch && git checkout 'origin/${SPRINT_BRANCH}') || (echo 'ddev exec...git checkout failed' && exit 102)"
printf "${YELLOW}Running 'ddev composer install'${RESET}...\n"
ddev composer install
ddev exec "git checkout /var/www/html/composer.*"

printf "${YELLOW}Running 'drush8 si' to install drupal.${RESET}...\n"
ddev exec "drush8 si --yes standard --account-pass=admin --db-url=mysql://db:db@db/db --site-name='Drupal Contribution Time'"
printf "${RESET}"
ddev describe

printf "
${GREEN}
####
# Use the following URL's to access your site:
#
# Website:    ${YELLOW}http://sprint-${TIMESTAMP}.ddev.site:8080/${GREEN}
#             ${YELLOW}https://sprint-${TIMESTAMP}.ddev.site:8443/${GREEN}
#             ${YELLOW}(U:admin  P:admin)${GREEN}
#
# ${GREEN}Mailhog:    ${YELLOW}http://sprint-${TIMESTAMP}.ddev.site:8025/${GREEN}
#
# phpMyAdmin: ${YELLOW}http://sprint-${TIMESTAMP}.ddev.site:8036/${GREEN}
#
# Chat:       ${YELLOW}https://drupal.org/chat to join Drupal Slack or https://drupalchat.me${GREEN}
#
# See ${YELLOW}Readme.txt${GREEN} for more information.
####
${RESET}
"
