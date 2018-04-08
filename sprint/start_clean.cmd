@echo off

ECHO ####
ECHO # This simple script starts a Drupal 8 checked out from head
ECHO # running in ddev with a fresh database.
ECHO #
ECHO # Make sure you've uploaded any patches from last issue
ECHO # you worked on before continuing, as this blow away
ECHO # local changes.
ECHO #
ECHO # Docker must be currently running.
ECHO #
ECHO # Press any key to continue
ECHO #
ECHO ####
PAUSE

START /WAIT ddev remove >nul
START /WAIT ddev start
ddev exec git fetch
ddev exec git reset --hard origin/8.6.x
ddev exec composer install
ddev exec drush si standard --account-pass=admin --db-url=mysql://db:db@db:3306/db
ddev exec drush cr
ddev describe

ECHO ####
ECHO # run the following command:
ECHO #
ECHO #   ddev hostname sprint-[ts].ddev.local 127.0.0.1
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
ECHO # For more info see README.txt
ECHO ####