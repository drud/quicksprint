# Drupal 8 Contribution Package

This directory contains tools to get you started contributing to Drupal 8:

* Drupal 8, already cloned with git
* Docker CE
* DDEV-Local (ddev) development environment
* Additional tools for Windows

## Prerequisites

* A computer with 8gb memory or greater.
* Windows 7 or higher, MacOS El Capitan or higher or a recent/stable Linux distribution.
* A robust code editor such as Visual Studio Code, Atom, PhpStorm or Netbeans (this may be provided as part of this package).

**⚠️ You can still install and contribute to Drupal even without these requirements using [Drupal's quick-start command](https://www.drupal.org/docs/8/install/quick-start-launch-a-local-demo-version-of-drupal-8-using-4-brief-steps)**!

## Getting Started

1. [Get The Files](#get-the-files)
2. [Extract drupal_sprint_package](#extract-files)
3. [Install Docker and Other Requirements](#install)
4. [Open Terminal](#open-terminal)
5. [Install Contribution Tools](#install-tools)

<a name="get-the-files"></a>
### 1. Get The Files

* USB Drive - Copy drupal_sprint_package-RELEASE.zip and Docker installer for your Operating System from the USB drive to your Desktop.
* ResilioSync - Find the folder/directory that was downloaded and copy its contents to your Desktop.
* GitHub - Download drupal_sprint_package-RELEASE.zip from https://github.com/drud/quicksprint/releases.

<a name="extract-files"></a>
### 2. Extract drupal_sprint_package directory

Extract the drupal_sprint_package.RELEASE.zip file, and open or browse to the "drupal_sprint_package" directory.

<a name="install"></a>
### 3. Install Docker and Other Requirements

#### 3.1 Docker CE or Docker Toolbox

Find the Docker installer for your Operating System underneath the **installs** directory. It is important to install the version of Docker provided for compatibility with the tools.

 Operating System | Docker Version | Installer
 ---------------- | -------------- | -----------------
 Windows 10 Pro, Enterprise (HyperV enabled) | Docker CE | "Docker for Windows Installer.exe"
 Windows 10 Home | Docker Toolbox | DockerToolbox-VERSION-ce.exe
 Windows 7 (or no HyperV enabled)| Docker Toolbox | DockerToolbox-VERSION-ce.exe
 MacOS | Docker CE | Docker.dmg
 Linux | Docker CE, docker-compose | See [Linux instructions](https://docs.docker.com/install/#docker-ce)

**⚠️Docker Toolbox users**: Please click the checkboxes to install "Git for Windows" and "VirtualBox" as needed during the install process.

**⚠️Docker Toolbox Users must start "Docker Quickstart Terminal" to start docker running.

**⚠️Docker for Windows and Docker for Mac** Start the docker application

**⚠️Docker for Windows**: You *must* share the C: drive (or any other drive your home directory may be on) under Docker->Settings->Shared Drives.

**⚠️All users:** additional information is available at [ddev docker instructions](https://ddev.readthedocs.io/en/latest/users/docker_installation/).

**⚠️Linux users:** You'll probably need the [ddev docker instructions](https://ddev.readthedocs.io/en/latest/users/docker_installation/) to get docker properly set up.

#### 3.2 ddev

**⚠️ Windows users**: Find the ddev_windows_installer.RELEASE.exe underneath the **ddev_tarballs** directory. Run it to install ddev at this time.

#### 3.3 Git

**⚠️ Windows users**:  Git Bash is used for all installation scripts, and of course you'll need git to be able to develop patches. [Helpful guide to git for Drupal](https://www.drupal.org/documentation/git). Find the Git-RELEASE-64-bit.exe installer underneath the **installs** directory.

<a name="open-terminal"></a>
### 4. Open Terminal

Open your Terminal application:

Operating System | Docker Version | Program
---------------- | -------------- | ----------------
Windows 10 Pro, Enterprise (HyperV enabled) | Docker CE | Git Bash
Windows 10 Home | Docker Toolbox | Docker Quickstart Terminal
Windows 7  | Docker Toolbox | Docker Quickstart Terminal
MacOS | Docker CE | Terminal.app or your preferred terminal application
Linux | Docker CE | Your preferred terminal application

<a name="install-tools"></a>
### 5. Install Contribution Tools

1. Change directory to the drupal_sprint_package directory using the `cd` command:
   * Example: Run `cd ~/Desktop/drupal_sprint_package`
2. Run the `install.sh` command and follow the prompts.
   * Example: `./install.sh`
3. Follow the instructions that print out at the end of the previous command to create a "sprint instance".
   * Example: `cd ~/sprint` and `./start_sprint.sh`.
4. Follow the instructions that print out at the end of the `./start_sprint.sh` command:
   1. Change directory into the newly created directory named `sprint-YYYYMMDD-HHMM` (with today's date and the time you ran `start_sprint`).
   2. Run `./start_clean.sh` to start your Drupal environment!

This may take a few minutes and will provide you with a set of URLs and further instructions for using your contribution environment.
