# Start from Debian stable (Buster)
FROM debian:stable

# Add backports repository
RUN echo 'deb http://deb.debian.org/debian/ buster-backports main contrib non-free' >>/etc/apt/sources.list

# Install the required package
RUN apt -qq update

# Create a dedicated user for simplecdd
RUN useradd -ms /bin/dash cdbuild

# Copy the SSH key into the misc directory, that will be put on the CD image
RUN mkdir -p /home/cdbuild/misc/root/.ssh
COPY --chown=cdbuild:cdbuild ./config/authorized_keys /home/cdbuild/misc/root/.ssh/authorized_keys

# Display available disk space
RUN df -h

# Install the last version of ansible to build the preseed file
RUN apt-get -qq install -y ansible
RUN apt-get clean

RUN apt-get -qq install -y debian-archive-keyring
RUN apt-get clean

# Install the last version of simple-cdd and debian keyrings
RUN apt-get -q install -y simple-cdd
RUN apt-get clean

# Install the last version of simple-cdd and debian keyrings
RUN apt-get -q install -y python
RUN apt-get clean

# Remove expired keys from Debian keyring
# RUN apt-key --keyring /usr/share/keyrings/debian-archive-keyring.gpg del ED6D65271AACF0FF15D123036FB2A1C265FFB764

# Copy the miscellaneous files to be part of the CD image
# but remove the doc file
COPY --chown=cdbuild:cdbuild ./misc /home/cdbuild/misc/
RUN rm -f /home/cdbuild/misc/readme.md

# Copy the playbooks and the configuration
COPY --chown=cdbuild:cdbuild ./playbooks /home/cdbuild/playbooks/
COPY --chown=cdbuild:cdbuild ./config /home/cdbuild/config/

# Build the ISO image
USER cdbuild
WORKDIR /home/cdbuild

# Copy the Ansible configuration file
COPY --chown=cdbuild:cdbuild ansible/ansible.cfg /home/cdbuild

# Create a simple host file for localhost to avoid Ansible warning
COPY --chown=cdbuild:cdbuild ansible/hosts.yml /home/cdbuild

# Run the ansible playbook
RUN ansible-playbook -vv -i hosts.yml -l localhost playbooks/docker.yml

# Build the mirror using simple-cdd
RUN cd /tmp/build-homebox && ./build-mirror.sh

# And build the CD image
RUN cd /tmp/build-homebox && ./build-cd.sh


# The ISO image is in this folder, but copying to the host
# seems unstable and problematic
RUN md5sum /home/cdbuild/debian-images/*iso

RUN test -d /tmp/debian-images/ || mkdir /tmp/debian-images/
RUN test -d /tmp/debian-images/isos || mkdir /tmp/debian-images/isos/

ENTRYPOINT cp /home/cdbuild/debian-images/* /tmp/debian-images/isos/
