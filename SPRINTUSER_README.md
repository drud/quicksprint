# Drupal 8 Sprint Package

This directory contains tools to get you going at a Drupal 8 sprint:

* Drupal 8, already cloned with git (`git clone git://git.drupal.org/project/drupal.git`)
* Docker (you must install it yourself; install images are provided in the installs directory)
* Git For Windows (for Windows Users)
* DDEV-Local (ddev) development environment

Prerequisites:

**Windows Prerequisites:**
* Windows 10 Professional/Enterprise: Please use Docker for Windows (bundled); Hyper-V must be enabled. If you don't have these, the Docker install process will typically prompt for the settings. 
* Windows 10 Home: Please use Docker Toolbox (bundled).
* [Git for Windows](https://gitforwindows.org/): git-bash is used for all installation scripts, and of course you'll need git to be able to develop patches. [Helpful git setup info at github](https://help.github.com/articles/set-up-git/). 
* ddev Windows Installer (bundled)

**macOS and Linux Prerequisites**
* Docker-for-Mac (bundled) or for Linux. See [detailed instructions](https://ddev.readthedocs.io/en/latest/users/docker_installation/)

**Installation and Startup:**

1. Install Docker CE if you don't already have it
  - **macOS/Windows**: There may be installers supplied with this package
  - **Linux**: See [Linux instructions](https://docs.docker.com/install/#docker-ce)
2. Start Docker (it must be running to install ddev)
3. Install DDEV-Local:
  - Run install_ddev.sh via terminal (git-bash on Windows) from the directory where this SPRINTUSER_README.md is with `./install_ddev.sh` - On Windows also run the ddev_windows_installer bundled.
4. Create Drupal 8 instance to use during sprint:
  - cd to `~/sprint` and run `./start_sprint.sh`
5. There should be a new sprint folder named `sprint-YYYYMMDD-HHMM` (with today's date and the time you ran `start_sprint`). Start the Drupal environment by using cd to move to the dated sprint folder, and run `./start_clean.sh`
6. After start_clean is finished, it will provide you with a set of URLs and further instructions for using your sprint environment.
