@echo off

CLS

REM # This script creates a new drupal 8 instance in the current directory ready to sprint on an issue.
REM #Create a timestamp
for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year^,Hour^,Minute /FORMAT:TABLE
') do (
    for /F "tokens=1-5" %%L in ("%%F") do (
        set DAY=0%%L
        set HOUR=0%%M
        set MINUTE=0%%N
        set MONTH=0%%O
        set YEAR=%%P
    )
)

set DAY=%DAY:~-2%
set HOUR=%HOUR:~-2%
set MINUTE=%MINUTE:~-2%
set MONTH=%MONTH:~-2%

set TIMESTAMP=%YEAR%%MONTH%%DAY%-%HOUR%%MINUTE%

REM #Extract a new ddev D8 core instance to $CWD/sprint-$TIMESTAMP
bin\7za.exe x sprint.tar.xz -so > nul | bin\7za.exe x -aoa -si -ttar -osprint-%TIMESTAMP% > nul

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
