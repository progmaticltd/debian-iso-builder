#!/bin/dash

# This is a simple script that buid the CD image
# inside a docker container running simple-cdd on Debian stretch
# The most important is the configuration file 'system.yml' in the preseed folder

# Build the docker image
docker-compose build cdbuild

# Create the temporary folder that will contains the ISO image for the installer
test -d /tmp/debian-images || mkdir /tmp/debian-images

# If your user ID is different from 1000, make sure the group 1000 can create this file:
mygroup=$(groups | cut -d ' ' -f 1)
chgrp "$mygroup" /tmp/debian-images
chmod g+wx /tmp/debian-images

# Run the docker container, that will do the following:
# 1 - Install the latest version of Ansible
# 2 - Run the Ansible playbook to create simple-cdd configuration
# 3 - Run simple-cdd to create custom iso image installer
docker run \
    --mount type=bind,source=/tmp/debian-images,target=/tmp/debian-images \
    cdbuild:latest || exit 1

# TODO: Move the installer to the backup folder, with a proper name
