# quicksprint

A basic toolkit to get people started with ddev and a Drupal codebase. This is intended for code sprints where lots of people need to get started with the same environment in a short period of time.

It uses [DDEV-Local](https://github.com/drud/ddev), docker, and a cloned Drupal8 repository to provide the tools to get people going quickly at a sprint.

* To create a sprint package, run the script package_sprint.sh. (You can also retrieve a tarball or zipball of the results at https://github.com/drud/quicksprint/releases instead of doing this step.)
* Your users will then unarchive the tarball or zipball. 
* Linux and Mac users run install_ddev.sh, Windows users run install_ddev.cmd inside the directory created by the tarball.
* Linux and Mac users can start up drupal8.ddev.local by running start_ddev.sh (or just executing commands like those in the simple script). Windows users run start_ddev.cmd.
* _Windows users must run an additional command_: In an administrative shell or cmd window they must run the command 
`ddev hostname drupal8.ddev.local 127.0.0.1`

At this point the plain vanilla git-checked-out drupal8 HEAD version should be running at http://drupal8.ddev.local 

