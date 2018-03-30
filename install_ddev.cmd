@echo off

CLS

set CURRENT_DIR=%CD%

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
ECHO #  -Do a git pull to ensure you have latest commits for core
ECHO #  -Pre-load docker images for the sprint toolkit:
ECHO #    -Drupal 8
ECHO #    -phpmyadmin
ECHO #    -Coud9 IDE
ECHO #    -Thelounge IRC client
ECHO #
ECHO # Press y to continue
ECHO # !!You don't need to hit enter!!.
ECHO ####
PAUSE

cd %~dp0

SET /p docker="Do you need to install Docker for Windows? [y/n]: " %=%
IF %docker% == y (
  REM Install Docker for Windows.
  "docker_installs\Docker^%20for^%20Windows^%20Installer.exe" 
  ECHO Once Docker installation is complete, 
  ECHO Open Docker preferances and increase memory allocation to 3.0GiB.
  ECHO Wait for Docker to restart before continuing.
  ECHO Hit any key once complete.
  PAUSE
)

ECHO "Installing docker images for ddev to use..."
cd ddev_tarballs
set /p LATEST_VERSION=<..\.latest_version.txt
..\bin\windows\7za x ddev_docker_images.%LATEST_VERSION%.tar.xz
docker load -i ddev_docker_images.%LATEST_VERSION%.tar

if exist docker_additions.tar.xz (
	..\bin\windows\7za x docker_additions.tar.xz
	docker load -i docker_additions.tar
)

ECHO "Installing ddev..."
..\bin\windows\7za x ddev_windows.%LATEST_VERSION%.zip
copy ddev.exe %HOMEPATH%\AppData\Local\Microsoft\WindowsApps

MKDIR "%userprofile%\Sites\sprint"
MKDIR "%userprofile%\Sites\sprint\bin"
COPY "%CURRENT_DIR%\bin\windows\7za.exe" "%userprofile%\Sites\sprint\bin"
COPY "%CURRENT_DIR%\bin\windows\sed.exe" "%userprofile%\Sites\sprint\bin"
COPY "%CURRENT_DIR%\bin\windows\regex2.dll" "%userprofile%\Sites\sprint\bin"
COPY "%CURRENT_DIR%\bin\windows\libintl3.dll" "%userprofile%\Sites\sprint\bin"
COPY "%CURRENT_DIR%\bin\windows\libiconv2.dll" "%userprofile%\Sites\sprint\bin"
COPY "%CURRENT_DIR%\start_sprint.cmd" "%userprofile%\Sites\sprint\"
COPY "%CURRENT_DIR%\sprint.tar.xz" "%userprofile%\Sites\sprint\"

ECHO ######
ECHO #
ECHO # Your ddev and the sprint kit are now ready to use, 
ECHO # execute the following commands now to start:
ECHO #
ECHO # cd %userprofile%\Sites\sprint
ECHO # start_sprint.cmd
ECHO #
ECHO ######
