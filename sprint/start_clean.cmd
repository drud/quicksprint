@echo off

REM check docker is running, via https://stackoverflow.com/a/1329790
tasklist /FI "IMAGENAME eq com.docker.service" | findstr /i /c:"com.docker.service"
if %ERRORLEVEL%==0 (
    ECHO Docker is running, continuing.
) ELSE (
    ECHO Docker is not running and is required for this script, exiting.
    EXIT
)

ECHO ####
ECHO # This simple script starts a Drupal 8 checked out from head
ECHO # running in ddev with a fresh database.
ECHO #
ECHO # Make sure you've uploaded any patches from last issue 
ECHO # you worked on before continuing, as this will blow away
ECHO # local changes.
ECHO #
ECHO # Press any key to continue
ECHO #
ECHO ####
PAUSE

ddev start
ddev exec git fetch
ddev exec git reset --hard origin/8.6.x
ddev exec rm -rf vendor/bin
ddev exec composer install
ddev exec drush si standard --account-pass=admin --db-url=mysql://db:db@db:3306/db --site-name="Drupal Sprinting"
ddev exec drush cr
ddev describe

ECHO ####
ECHO # Please run the following command in an admin cmd or powershell window:
ECHO # 
ECHO #   ddev hostname sprint-[ts].ddev.local 127.0.0.1
ECHO #
ECHO # Website:     http://sprint-[ts].ddev.local:8080/
ECHO #              https://sprint-[ts].ddev.local:8443/
ECHO #              (U:admin  P:admin)
ECHO #
ECHO # IDE: 		http://sprint-[ts].ddev.local:8000/
ECHO #				(U:username  P:password)
ECHO #
ECHO # Mailhog: 	http://sprint-[ts].ddev.local:8025/
ECHO #
ECHO # DB Admin: 	http://sprint-[ts].ddev.local:8036/
ECHO #
ECHO # IRC: 		http://sprint-[ts].ddev.local:9000/
ECHO #
ECHO # IDE: 		http://sprint-[ts].ddev.local:8000/
ECHO #				(U:username  P:password)
ECHO #
ECHO # For more info see Readme.txt
ECHO ####