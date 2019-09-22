#!/bin/dash

# This is a simple script that buid the CD image
# inside a docker container running simple-cdd on Debian stretch
# The most important is the configuration file 'system.yml' in the preseed folder

# Build the docker image
docker-compose build cdbuild

TMP_DIR=/tmp

# Create the temporary folder that will contains the ISO image for the installer
test -d $TMP_DIR/debian-images || mkdir $TMP_DIR/debian-images

# If your user ID is different from 1000, make sure the group 1000 can create this file:
mygroup=$(groups | cut -d ' ' -f 1)
chgrp "$mygroup" /tmp/debian-images
chmod g+wx $TMP_DIR/debian-images

# Set shared directories
host_dir="/tmp/debian-images"
test -d "$host_dir" || mkdir "$host_dir"

# Mount options for Docker
test -d $TMP_DIR/debian-images/isos || mkdir $TMP_DIR/debian-images/isos
mountOptions="--volume $TMP_DIR/debian-images:$TMP_DIR/debian-images"

# Run the docker container, that will do the following:
# 1 - Install the latest version of Ansible
# 2 - Run the Ansible playbook to create simple-cdd configuration
# 3 - Run simple-cdd to create custom iso image installer
docker run -i --shm-size=256m $mountOptions cdbuild:latest || exit 1

# Copy the ISO image in the temporary folder
cpcmd="cp -v /tmp/build-homebox/images/*iso /tmp/homebox-images/"
echo "$cpcmd" | docker run -i -v $TMP_DIR/homebox-images:$TMP_DIR/homebox-images:shared cdbuild:latest
