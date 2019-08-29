#!/bin/bash
# Based on: https://github.com/jupyter/docker-stacks/blob/master/base-notebook/fix-permissions
# set permissions on a directory
# after any installation, if a directory needs to be (human) user-writable,
# run this script on it.
# It will make everything in the directory owned by the group with $USER_GID
# and writable by that group.
# Deployments that want to set a specific user id can preserve permissions
# by adding the `--group-add users` line to `docker run`.

# uses find to avoid touching files that already have the right permissions,
# which would cause massive image explosion

# right permissions are:
# group=$USER_GID
# AND permissions include group rwX (directory-execute)
# AND directories have setuid,setgid bits set

# Exit immediately if a command exits with a non-zero status.
set -e

if [ -z "$USER_GID" ]; then
    echo "Please set a user GID via USER_GID env varibale."
    exit 1
fi

for d in $@; do
  find "$d" \
    ! \( \
      -group $USER_GID \
      -a -perm -g+rwX  \
    \) \
    -exec chgrp $USER_GID {} \; \
    -exec chmod g+rwX {} \;
  # setuid,setgid *on directories only*
  find "$d" \
    \( \
        -type d \
        -a ! -perm -6000  \
    \) \
    -exec chmod +6000 {} \;
done
