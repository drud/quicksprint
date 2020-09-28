# Drupal Contribution Package

This package contains tools to get you started contributing to Drupal:

* Drupal, already cloned with git
* Docker Desktop for Mac or Windows
* DDEV-Local (ddev) development environment
* Additional tools including git for Windows

## Prerequisites

* A computer with 6gb memory or greater.
* Windows 10 or higher (with WSL2 and/or Hyper-V support), MacOS High Sierra or higher or a recent/stable Linux distribution.
* A robust code editor such as Visual Studio Code, Atom, PhpStorm or Netbeans (this may be provided as part of this package).

**⚠️ If your computer does not match a requirement, try the [Drupal quick-start](https://www.drupal.org/docs/8/install/quick-start-launch-a-local-demo-version-of-drupal-8-using-4-brief-steps)**! Now skip the steps below.

## Getting Started

1. [Get The Files](#get-the-files)
2. [Extract drupal_sprint_package](#extract-files)
3. [Install Docker and Other Requirements](#install)
4. [Open Terminal](#open-terminal)
5. [Install Contribution Tools](#install-tools)

<a name="get-the-files"></a>
### 1. Get The Files

Use one of the options below to get the files.

* GitHub - Download `drupal_sprint_package.<RELEASE>.zip` from https://github.com/drud/quicksprint/releases. Also download `quicksprint_thirdparty_installs.<RELEASE>>.zip` if you need Docker and/or Git.
* USB Drive (available at some conferences) - Copy drupal_sprint_package.RELEASE.zip and Docker installer for your Operating System from the USB drive to your Desktop.
* ResilioSync (available at some conferences) - Find the folder/directory that was downloaded and copy its contents to your Desktop.


<a name="extract-files"></a>
### 2. drupal_sprint_package directory

Extract the `drupal_sprint_package.<RELEASE>.zip` file, and open or browse the contents. This is the sprint package directory.

Extract the `quicksprint_thirdparty_installs.<RELEASE>.zip` if downloaded, and open or browse the contents and find the /installs folder. This is the third party installs directory.

<a name="install"></a>
### 3. Install Docker and Other Requirements

#### 3.1 Docker Desktop

* **Windows users install git:** First, install Git For Windows from the **third party installs** directory. The version here is newer than you might have on your computer if you already have it, so install if you don't have Git for Windows or have a version less than 2.21.0.
* **All users:** Find the Docker installer for your Operating System underneath the **third party installs** directory. It is important to install the version of Docker provided for compatibility with the tools.

 Operating System | Docker Version             | Installer
 ---------------- | -------------------------- | -----------------
 Windows 10       | Docker Desktop for Windows | "Docker for Windows Installer.exe"
 MacOS            | Docker Desktop for Mac     | Docker.dmg
 Linux            | Docker CE, docker-compose  | See [Linux instructions](https://docs.docker.com/engine/install/#server)

**⚠️Docker Desktop for Windows**: Docker Desktop prompts you to enable WSL 2 during installation.

**⚠️All users** Additional Docker **installation** troubleshooting and installation documentation is available at [ddev docker instructions](https://ddev.readthedocs.io/en/stable/users/docker_installation/).

-**⚠️Linux users:** You'll probably need the [ddev docker instructions](https://ddev.readthedocs.io/en/stable/users/docker_installation/) to confirm your versions of docker ce and docker-compose to get docker properly setup.

**⚠️All users:** Now start the Docker application you installed. Docker may ask you to create a DockerHub user account, and you may ignore this prompt safely and continue on below.

<a name="open-terminal"></a>
### 4. Open Terminal

Open your Terminal application. If you already had a window open, **close it and open another one**.

Operating System | Docker Version             | Program
---------------- | -------------------------- | ----------------
Windows 10       | Docker Desktop             | Git Bash
MacOS            | Docker Desktop             | Terminal.app or your preferred terminal application
Linux            | Docker CE, docker-compose  | Your preferred terminal application

<a name="install-tools"></a>
### 5. Install Contribution Tools

1. Change directory to the `drupal_sprint_package` directory using the `cd` command:
   * Example: Run `cd ~/Desktop/drupal_sprint_package`
2. Run the `install.sh` command and follow the prompts.
   * Example: `./install.sh`
3. Follow the instructions that print out at the end of the previous command to create a sprint instance.
   * Example: `cd ~/sprint` and `./start_sprint.sh`.

This may take a few minutes and will provide you with a set of URLs and further instructions for using your contribution environment.

