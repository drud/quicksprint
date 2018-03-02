
echo "Installing ddev"

if ! docker --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker is required for ddev. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
fi

echo "Installing docker images for ddev to use..."
cd ddev_tarballs
../bin/7za x ddev_docker_images*.gz
docker load -i ddev_docker_images*.tar

../bin/7za x ddev_windows*.zip
copy ddev.exe %HOMEPATH%\AppData\Local\Microsoft\WindowsApps


echo "ddev is now installed. Run \"ddev\" to verify your installation and see usage."
