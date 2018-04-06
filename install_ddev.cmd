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

FOR %%X in (docker.exe) do (set FOUND=%%~$PATH:X)
IF defined FOUND
  ECHO ######
  ECHO # Docker found! Make sure it's version 18.03.0 and running before continuing.
  ECHO #
  ECHO # Open Docker preferences, confirm the memory allocation is set to 3.0 GiB
  ECHO # on the Advanced tab, and that docker has fully restarted before continuing.
  ECHO #
  ECHO # Hit any key once Docker has restarted.
  ECHO ######
  PAUSE
) ELSE (
  ECHO ######
  ECHO # You need to install Docker and have it running before executing this script.
  ECHO #
  ECHO # The installer is likely provided in a docker_installs directory with this package.
  ECHO # Otherwise get it at https://docs.docker.com/docker-for-windows/release-notes/
  ECHO #
  ECHO ######
  EXIT
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
