# Drupal 8 Sprint Package

This directory contains tools to get you going at a Drupal 8 sprint:

* Drupal 8, already cloned with git (`git clone git://git.drupal.org/project/drupal.git`)
* Docker (you must install it yourself; install images are provided in the docker_installs directory)
* DDEV-Local (ddev) development environment

Prerequisites: 

* This project on Windows requires Windows 10 Pro, with Hyper-V enabled and virtualization additions enabled in your BIOS. If you don't have these, the Docker install process will typically prompt for the settings. Windows 10 Home and Enterprise, and earlier Windows versions are not supported.
* You'll need git to be able to develop patches. [Helpful git setup info at github](https://help.github.com/articles/set-up-git/). Note that git is available inside the web container (`ddev ssh`) if you don't have it on your host computer.

Installation and Startup:

1. Install docker-ce if you don't already have it. (macOS and Windows): There are install images in the docker_installs directory of this folder.  (Linux) See [Linux instructions](https://docs.docker.com/install/#docker-ce)
2. Start docker (it must be running to install ddev)
3. Install DDEV-Local. (macOS/Linux): Run install_ddev.sh in the directory where this SPRINTUSER_README.md is with `./install_ddev.sh`; (Windows): run `install_ddev.cmd`.
4. Start up Drupal 8: (macOS/Linux): cd to `~/Sites/sprint` and run `./start_sprint.sh` - (Windows): run `start_sprint.cmd` in `%userprofile%\Sites\sprint`
5. _Windows users must run an additional command_: the start_clean command will tell you what the command is.
