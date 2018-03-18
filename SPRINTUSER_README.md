# Drupal 8 Sprint Package

This directory contains all the tools to get you going at a Drupal 8 sprint:

* Drupal 8, already cloned with git (`git clone git://git.drupal.org/project/drupal.git`)
* Docker (you must install it yourself)
* DDEV-Local (ddev) development environment

Prerequisites: 

* You'll need git to be able to develop patches. [Helpful git setup info at github](https://help.github.com/articles/set-up-git/).

Installation and Startup:

1. (Linux) Install docker-ce if you don't already have it. ([Linux instructions](See the Docker CE section at this page for linux installation instructions https://docs.docker.com/install/#server))
2. (macOS/Linux): Install DDEV-Local by running install_ddev.sh in this directory: `./install_ddev.sh` - (Windows): run install_ddev.cmd
3. (macOS/Linux): After installed you can start up an instance by cd'ing to `~/Sites/sprint` and running `start_sprint.sh` - (Windows): run `start_sprint.cmd` from `%userprofile%\Sites\sprint`
4. _Windows users must run an additional command_: the start_clean command will tell you what the command is.
