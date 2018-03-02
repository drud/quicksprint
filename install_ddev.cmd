
echo "Installing ddev"

if ! docker --version >/dev/null 2>&1; then
    printf "${YELLOW}Docker is required for ddev. Download and install docker at https://www.docker.com/community-edition#/download before attempting to use ddev.${RESET}\n"
fi

echo "Installing docker images for ddev to use..."
cd ddev_tarballs
7z x ddev_docker_images*.gz
docker load -i ddev_docker_images*.tar

unzip $TARBALL -C /tmp
chmod ugo+x /tmp/ddev

printf "Ready to place ddev in your /usr/local/bin.\n"

if [[ "$BINOWNER" == "$USER" ]]; then
    mv /tmp/ddev /usr/local/bin/
else
    printf "${YELLOW}Running \"sudo mv /tmp/ddev /usr/local/bin/\" Please enter your password if prompted.${RESET}\n"
    sudo mv /tmp/ddev /usr/local/bin/
fi

if which brew &&  [ -f `brew --prefix`/etc/bash_completion ]; then
	bash_completion_dir=$(brew --prefix)/etc/bash_completion.d
    cp /tmp/ddev_bash_completion.sh $bash_completion_dir/ddev
    printf "${GREEN}Installed ddev bash completions in $bash_completion_dir${RESET}\n"
    rm /tmp/ddev_bash_completion.sh
fi

printf "${GREEN}ddev is now installed. Run \"ddev\" to verify your installation and see usage.${RESET}\n"
