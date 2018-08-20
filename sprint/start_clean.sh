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
    printf "docker is running, continuing."
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

printf "
${GREEN}
####
# This script starts a Drupal 8 instance checked out from head
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

echo "${YELLOW}Configuring your fresh Drupal8 instance. This takes a few minutes.${RESET}"
ddev start
ddev exec bash -c 'git fetch && git reset --hard origin/8.7.x && composer install && drush si standard --account-pass=admin --db-url=mysql://db:db@db/db --site-name="Drupal Sprinting" && drush cr'
printf "${RESET}"
ddev describe

printf "
${GREEN}
####
# Use the following URL's to access your site:
#
# Website:    ${YELLOW}http://sprint-[ts].ddev.local:8080/${GREEN}
#             ${YELLOW}https://sprint-[ts].ddev.local:8443/${GREEN}
#             ${YELLOW}(U:admin  P:admin)${GREEN}
#
# ${GREEN}Mailhog:    ${YELLOW}http://sprint-[ts].ddev.local:8025/${GREEN}
#
# phpMyAdmin: ${YELLOW}http://sprint-[ts].ddev.local:8036/${GREEN}
#
# Chat:       ${YELLOW}https://drupal.org/chat to join Drupal Slack or drupalchat.eu!${GREEN}
#
# See ${YELLOW}Readme.txt${GREEN} for more information.
####
${RESET}
"
