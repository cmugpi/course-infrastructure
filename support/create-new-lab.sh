#!/usr/bin/env bash

# This script takes care of all the boilerplate for creating a new lab.
# It sets up the directory structure and creates a symlink to the Makefile.

if [ $# -eq 0 ]
  then
    echo "usage: ./support/create-new-lab.sh <foolab>"
    echo "  Ensure you are in the top level directory, where all other labs are."
    exit 1
fi

labname="$1"

mkdir -p "$labname/src/refsol"
mkdir -p "$labname/src/dist/driver"
mkdir -p "$labname/src/driver-private/tests"
mkdir -p "$labname/src/driver-public/tests"
ln -s ../shared/Baskfile "$labname/Baskfile"

echo '#!/usr/bin/env bash

REQUIRED_FILES="
"' > "$labname/config"
