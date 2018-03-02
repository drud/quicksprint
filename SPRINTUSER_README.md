# Drupal 8 Sprint Package

This directory contains all the tools to get you going at a Drupal 8 sprint:

* Drupal 8, already cloned with git (`git clone git://git.drupal.org/project/drupal.git`)
* Docker (you must install it yourself)
* DDEV-Local (ddev) development environment

Here are the steps to get started:

Prerequisites: 

* You'll need git to be able to develop patches. [Helpful git setup info at github](https://help.github.com/articles/set-up-git/).

Installation:

1. Install docker-ce if you don't already have it. Working installs for macOS and Windows are in the docker_installs directory. If you're running Linux, check Docker's website for install instructions. ([Ubuntu instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/))
2. (macOS/Linux): Install DDEV-Local by running install_ddev.sh in this directory: `./install_ddev.sh` - (Windows): run install_ddev.cmd
3. (macOS/Linux): Start ddev with start_ddev.sh in this directory: `./start_ddev.sh` - (Windows): run start_ddev.cmd
4. _Windows users must run an additional command_: In an administrative shell or cmd window they must run the command 
`ddev hostname drupal8.ddev.local 127.0.0.1`

