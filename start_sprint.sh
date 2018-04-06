#!/bin/bash
clear

# This script creatse a new drupal 8 instance in the current directory ready to sprint on an issue.

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'
OS=$(uname)
#Create a timestamp
TIMESTAMP=$(date +"%Y%m%d-%H%M")

#Extract a new ddev D8 core instance to $CWD/sprint-$TIMESTAMP
mkdir -p sprint-$TIMESTAMP
tar xpf sprint.tar.xz -C sprint-$TIMESTAMP
wait

#Update ddev project name
if [[ "$OS" == "Darwin" ]]; then
	sed -i '' 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/.ddev/config.yaml
	sed -i '' 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/Readme.txt
	sed -i '' 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/start_clean.sh
	sed -i '' 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/start_clean.cmd
elif [[ "$OS" == "Linux" ]]; then
	sed -i 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/.ddev/config.yaml
	sed -i 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/Readme.txt
	sed -i 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/start_clean.sh
	sed -i 's/\[ts\]/'${TIMESTAMP}'/' sprint-$TIMESTAMP/start_clean.cmd
fi

printf "${GREEN}
######
#
# Your Drupal 8 instance is now ready to use, 
# execute the following commands in terminal 
# to start a Drupal 8 instance to sprint on:
#
# ${YELLOW}cd sprint-${TIMESTAMP}${GREEN}
# ${YELLOW}./start_clean.sh${GREEN}
#
######
${RESET}
"