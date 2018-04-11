# Drupal 8 Sprint Package

This directory contains tools to get you going at a Drupal 8 sprint:

* Drupal 8, already cloned with git (`git clone git://git.drupal.org/project/drupal.git`)
* Docker (you must install it yourself; install images are provided in the docker_installs directory)
* DDEV-Local (ddev) development environment

Prerequisites:

* This project on Windows requires Windows 10 Pro, with Hyper-V enabled and virtualization additions enabled in your BIOS. If you don't have these, the Docker install process will typically prompt for the settings. Windows 10 Home and Enterprise, and earlier Windows versions are not supported.
* You'll need git to be able to develop patches. [Helpful git setup info at github](https://help.github.com/articles/set-up-git/). Note that git is available inside the web container (`ddev ssh`) if you don't have it on your host computer.

Installation and Startup:

1. Install Docker CE if you don't already have it
  - **macOS/Windows**: There may be installers supplied with this package
  - **Linux**: See [Linux instructions](https://docs.docker.com/install/#docker-ce)
2. Start Docker (it must be running to install ddev)
3. Open Docker preferences and set docker memory allocation to 3.0GB in the Advanced section (required for container to be started)
3. Install DDEV-Local:
  - **macOS/Linux**: Run install_ddev.sh via terminal from the directory where this SPRINTUSER_README.md is with `./install_ddev.sh`
  - **Windows**: Run `install_ddev.cmd`
4. Create Drupal 8 instance to use during sprint:
  - **macOS/Linux**: cd to `~/Sites/sprint` and run `./start_sprint.sh`
  - **Windows**: run `start_sprint.cmd` in `%userprofile%\Sites\sprint`
5. There should be a new sprint folder named `sprint-YYYYMMDD-HHMM` (with today's date and the time you ran `start_sprint`). Start the Drupal environment using start_clean:
  - **macOS/Linux**: cd into the dated sprint folder, and run `./start_clean.sh`
  - **Windows**: run `start_clean.cmd` in the dated sprint folder
6. After start_clean is finished, it will provide you with a set of URLs and further instructions for using your sprint environment.
7. _Windows users only_: To be able to access the sprint site, after start_clean is finished:
  1. Copy the `ddev hostname` command that's provided near the end of the output.
  2. Open a new PowerShell or cmd instance as an administrator (choose 'Run as Administrator').
  3. Paste that command and run it. It will place an entry in your hosts file so you can access the site URL provided by DDEV-Local.
