@echo off

CLS

ECHO ####
ECHO # This script will install everything you need to participate in this sprint.
ECHO #
ECHO # Feel free to first inspect the script before continuing if you like.
ECHO #  -To do this just open it with a text editor
ECHO #
ECHO # It does the following:
ECHO #  -Install Docker for your OS if you don't have it already
ECHO #  -Install ddev by Drud Technology
ECHO #  -Copy required components to ~/Sites/sprint/
ECHO #  -Pre-loaded docker images for the sprint toolkit:
ECHO #    -Drupal 8
ECHO #    -phpmyadmin
ECHO #    -Cloud9 IDE
ECHO #    -Thelounge IRC client
ECHO #
ECHO # Press y to continue
ECHO # !!You don't need to hit enter!!.
ECHO ####
PAUSE

cd %~dp0

FOR /f "delims=" %%a in ('WHERE docker') do @set FOUND=%%a
IF DEFINED FOUND (
  ECHO ######
  ECHO # Docker found! Make sure it's version 18.03.0 and running before continuing.
  ECHO #
  ECHO # Open Docker preferences, on the Shared Drives tab share all of your
  ECHO # local drives, on the Advanced tab set the memory allocation to 3.0 GiB
  ECHO # then click apply.
  ECHO #
  ECHO # Ensure that docker has fully restarted before continuing.
  ECHO #
  ECHO # Hit any key once Docker has restarted.
  ECHO ######
  PAUSE
) ELSE (
  ECHO ######
  ECHO # You need to install Docker and have it running before executing this script.
  ECHO #
  ECHO # The installer may be provided with this package.
  ECHO # Otherwise get it at https://docs.docker.com/docker-for-windows/release-notes/
  ECHO #
  ECHO ######
  EXIT
)

ECHO "Installing docker images for ddev to use..."
set /p LATEST_VERSION=<.latest_version.txt
bin\windows\7za -so x ddev_tarballs\ddev_docker_images.%LATEST_VERSION%.tar.xz | docker load

IF EXIST .\ddev_tarballs\docker_additions.tar.xz (
	bin\windows\7za -so x .\ddev_tarballs\docker_additions.tar.xz | docker load
)

ECHO "Installing ddev..."
bin\windows\7za -y x ddev_tarballs\ddev_windows.%LATEST_VERSION%.zip
move /y ddev.exe %HOMEDRIVE%%HOMEPATH%\AppData\Local\Microsoft\WindowsApps

MKDIR "%userprofile%\Sites\sprint"
MKDIR "%userprofile%\Sites\sprint\bin"
COPY /Y bin\windows\*.* "%userprofile%\Sites\sprint\bin"
COPY /Y start_sprint.cmd "%userprofile%\Sites\sprint\"
COPY /Y sprint.tar.xz "%userprofile%\Sites\sprint\"

ECHO ######
ECHO #
ECHO # Your ddev and the sprint kit are now ready to use, 
ECHO # execute the following commands now to start:
ECHO #
ECHO # cd %userprofile%\Sites\sprint
ECHO #
ECHO # Right click and run the following as administrator from explorer.
ECHO #
ECHO # start_sprint.cmd
ECHO #
ECHO ######
