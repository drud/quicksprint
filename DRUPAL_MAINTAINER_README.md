# Drupal Quicksprint Maintainer Notes

Quicksprint is a basic toolkit to get people started with ddev and a Drupal codebase. This is intended for contribution events where lots of people need to get started with the same environment in a short period of time.

There are two parts to this project:

1. A build of the tarball that a contribution event attendee needs (done by a maintainer using Linux or Mac OS, who should be reading this right now). The maintainer uses `package_drupal_script.sh` to create a tarball/zipball for sprint attendees to use.
2. A released tarball/zipball that has everything ready for an ordinary contributor to get set up fast. It includes a DRUPAL_SPRINTUSER_README.md to help them know what to do.

Quicksprint uses [DDEV-Local](https://github.com/drud/ddev), docker, and a cloned Drupal repository to provide the tools to get people going quickly at a contribution event.

## Creating a Sprint Package

Quicksprint packages are built nightly and on tagged releases. Please download a tagged release from the GitHub [Releases page](https://github.com/drud/quicksprint/releases) rather than bothering to build it yourself. But of course, you could create a custom build using this source repository.

* To create a package you will need to
    * Confirm Docker is running.
    * Confirm docker-compose is available.
    * Make sure you have these packages on your build machine: curl jq zcat composer perl zip bats. You can run the tests/sanetestbot.sh script to test.
    * Then run the script `package_drupal_script.sh`

## Distributing a Sprint Package

There are several ways to distribute your package such as through a peer-to-peer tool such as ResilioSync, USB flash drives or downloading from the releases page. This will depend on the size of your sprint.

You must provide both the contents of the `drupal_sprint_package` *and* the `installs` tarball. (The installs package grew too big for github releases.)

Method      | Sprint Size | Bandwidth | Other Considerations
----------  | ----------- | --------- | ----------------------
ResilioSync | 100+ users  | N/A       | ResilioSync is not screen reader friendly and may be conflict with Firewall/Access Point security settings. Theoretically everyone would be able to get the files at the same time.
USB drives  | varies      | N/A       | 30+ USB flash drives will work for large events, but people will be waiting in line.
Download    | 25 users    | 5 m/s     | Sprint venue may not be able to support large number of users pulling releases from github.

#### USB Flash Drives

There are some better tools to automate USB flash drive imaging, but your mileage may vary. The following is a no frills method of doing so.

1. Download the latest release(s) locally.
2. Add the files to a flash drive.
    * (MacOS only) Remove hidden directories added by Spotlight and Finder.
3. Determine the total file size used on the device: `du /path/to/volume` so you know what the count parameter should be in the dd command below.
    * **⚠️ Warning** If you are _overwriting_ an existing package on a flash drive then this number **must** be greater than the previous size!
4. Create a disk image using `dd if=/dev/DEVICE` of=~/sprint-package.img bs=1m count=2700`.
    * (MacOS only) Check the disk device with `diskutil list`.
5. Eject/Umount  the flash drive.
6. Insert a new flash drive.
    * (MacOS/Automount only) Unmount the flash drive if automounted - `diskutil unmount /dev/DEVICE`.
7. Reformat the flash drive (if the flash drive has files greater than the size of the disk image).
8. Write the image to the flash drive using `dd if=~/sprint-package.img of=/dew/DEVICE bs=1m`.
9. Eject and repeat 6. as necessary.

### Using your Sprint Package

* Your users will then download and unarchive the tarball or zipball.
* Run install.sh from the unarchived directory; (Windows users must work in git-bash).
* After installation, users can start up an instance by cd-ing to ~/sprint and running ./start_sprint.sh. 
