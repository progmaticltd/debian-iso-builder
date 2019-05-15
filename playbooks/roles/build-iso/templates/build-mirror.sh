#!/bin/bash

# The first parameter is the name of the server to build the iso image
export HOSTNAME={{ system.hostname }}

{% if debug %}
set -x
{% endif %}

# Use proxy if defined
{% if network.proxy is defined and network.proxy != False %}
export http_proxy='{{ network.proxy }}'
{% endif %}

# Parameters
DIST='{{ repo.release }}'
LOCALE='{{ locale.id }}'

# Build the default mirror URL
MIRROR='http://{{ repo.main }}/debian/'

# Build the mirror repositories option
MIRROR_OPTIONS="--do-mirror ${COMMON_OPTS} --mirror-only"

{% if debug %}
MIRROR_OPTIONS="$MIRROR_OPTIONS --debug"
{% else %}
MIRROR_OPTIONS="$MIRROR_OPTIONS --verbose"
{% endif %}

# Build the mirror
simple-cdd $MIRROR_OPTIONS

