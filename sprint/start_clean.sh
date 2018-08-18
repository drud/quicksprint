#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Check Docker is running
if docker run --rm -t busybox:latest ls >/dev/null
then
    printf "docker service running, continuing."
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

printf "
${GREEN}
####
# This simple script starts a Drupal 8 checked out from head
# running in ddev with a fresh database.
#
# Make sure you've uploaded any patches from last issue
# you worked on before continuing. This will revert all
# local code and database changes.
#
####
${RESET}"
while true; do
    read -p "Continue? (y/n): " INSTALL
    case $INSTALL in
        [Yy]* ) printf "${GREEN}# Continuing \n#### \n${RESET}"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done


# Attempts to reconfigure ddev to update config automagically.
ddev config --docroot drupal8 --projectname sprint-[ts] --projecttype drupal8

ddev start
ddev exec git fetch
ddev exec git reset --hard origin/8.7.x
ddev exec composer install
ddev exec drush si standard --account-pass=admin --db-url=mysql://db:db@db:3306/db --site-name="Drupal Sprinting"
ddev exec drush cr
ddev describe

printf "
${GREEN}
####
# Use the following URL's to access your site:
#
# Website:   ${YELLOW}http://sprint-[ts].ddev.local:8080/${GREEN}
#            ${YELLOW}https://sprint-[ts].ddev.local:8443/${GREEN}
#            ${YELLOW}(U:admin  P:admin)${GREEN}
#
# ${GREEN}Mailhog:   ${YELLOW}http://sprint-[ts].ddev.local:8025/${GREEN}
#
# DB Admin:  ${YELLOW}http://sprint-[ts].ddev.local:8036/${GREEN}
#
# See ${YELLOW}Readme.txt${GREEN} for more information.
####
${RESET}
"
