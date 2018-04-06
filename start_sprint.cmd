@echo off

set -o errexit
set -o pipefail
set -o nounset

CLS

goto check_Permissions

:check_Permissions
ECHO ######
ECHO #
ECHO # Administrative permissions required. Detecting permissions...
ECHO #

net session >nul 2>&1
IF %ERRORLEVEL% == 0 (
    ECHO # Success: Administrator permissions confirmed.
    ECHO #
    ECHO ######

) ELSE (
    ECHO # Failure: You need to run this as Administrator. Exiting...
    ECHO #
    ECHO ######
    EXIT /B 1
)

REM # This script creates a new drupal 8 instance in the current directory ready to sprint on an issue.
REM #Create a timestamp
set HOUR=%time:~0,2%
set SANEHOUR=%HOUR: 0=24%
set SANEHOUR=%HOUR: =0%
set TIMESTAMP=%date:~10,4%%date:~7,2%%date:~4,2%-%SANEHOUR%%time:~3,2%

REM #Extract a new ddev D8 core instance to $CWD/sprint-$TIMESTAMP
bin\7za.exe x sprint.tar.xz -so | bin\7za.exe x -aoa -si -ttar -osprint-%TIMESTAMP%

REM #Update ddevproject name
bin\sed.exe -i s/\[ts\]/%TIMESTAMP%/ sprint-%TIMESTAMP%/.ddev/config.yaml
bin\sed.exe -i s/\[ts\]/%TIMESTAMP%/ sprint-%TIMESTAMP%/Readme.txt
bin\sed.exe -i s/\[ts\]/%TIMESTAMP%/ sprint-%TIMESTAMP%/start_clean.sh
bin\sed.exe -i s/\[ts\]/%TIMESTAMP%/ sprint-%TIMESTAMP%/start_clean.cmd

ECHO ######
ECHO #
ECHO # Your Drupal 8 instance is now ready to use,
ECHO # execute the following commands in terminal
ECHO # to start a Drupal 8 instance to sprint on:
ECHO #
ECHO # cd sprint-%TIMESTAMP%
ECHO # start_clean.cmd
ECHO #
ECHO ######
