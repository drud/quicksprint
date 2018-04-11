# Quicksprint Maintainer Notes

Quicksprint is a basic toolkit to get people started with ddev and a Drupal codebase. This is intended for code sprints where lots of people need to get started with the same environment in a short period of time.

There are two parts to this project:

1. A build of the tarball that a sprint attendee needs (done by a maintainer using Linux or Mac OS, who should be reading this right now). The maintainer uses package_drupal_script.sh to create a tarball/zipball for sprint attendees to use.
2. A released tarball/zipball that has everything ready for an ordinary sprint user to get set up fast. It includes a SPRINTUSER_README.md to help them know what to do.

Quicksprint uses [DDEV-Local](https://github.com/drud/ddev), docker, and a cloned Drupal8 repository to provide the tools to get people going quickly at a sprint.

* To create a sprint package you will need Docker running, then run the script package_drupal_script.sh. (You can also retrieve a tarball or zipball of the results at https://github.com/drud/quicksprint/releases instead of doing this step.)
* Your users will then download and unarchive the tarball or zipball.
* Linux and Mac users run install_ddev.sh, Windows users run install_ddev.cmd inside the directory created by the tarball.
* After installation, Linux and Mac users can start up an instance by cd'ing to ~/Sites/sprint and running start_sprint.sh. Windows users run start_sprint.cmd in Sites/sprint of their user folder.
* _Windows users must run an additional command_: the start_clean command will tell you what the command is.

At this point the plain vanilla git-checked-out drupal8 HEAD version should be running at http://drupal8.ddev.local.

# Sources for additions

**7za.exe**
https://www.7-zip.org/download.html

**sed.exe and dependencies (libiconv2.dll, libintl3.dll, regex2.dll)**
http://gnuwin32.sourceforge.net/packages/sed.htm

**Cloud 9 IDE Docker image**
https://github.com/BrianGilbert/docker-cloud9/tree/20180318

**TheLounge IRC client Docker image**
https://github.com/linuxserver/docker-thelounge/tree/94