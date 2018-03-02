
echo "Installing ddev"

echo "Installing docker images for ddev to use..."
cd ddev_tarballs
set /p LATEST_VERSION=<..\.latest_version.txt
..\bin\7za x ddev_docker_images.%LATEST_VERSION%.tar.gz
docker load -i ddev_docker_images.%LATEST_VERSION%.tar

..\bin\7za x ddev_windows.%LATEST_VERSION%.zip
copy ddev.exe %HOMEPATH%\AppData\Local\Microsoft\WindowsApps


echo "ddev is now installed. Run \"ddev\" to verify your installation and see usage."

echo "You still must add drupal8.ddev.local to your hosts file"
echo "Please run this command in a cmd window with administrative privileges:"
echo "ddev hostname drupal8.ddev.local 127.0.0.1"
