#!/bin/sh

# run this scripts in your android app/library project root dir
COMMAND_SCRIPTS=$@
docker run --tty --interactive --volume=$(pwd):/opt/workspace --user `id -F` --workdir=/opt/workspace --rm quanken/android-ugbs-docker /bin/sh -c "$COMMAND_SCRIPTS"
