#!/usr/bin/env bash

# shellcheck disable=SC1091
source config

mkdir -p handin
unzip handin.zip -d handin

for file in $REQUIRED_FILES; do
  if [ ! -e "handin/$file" ]; then
    echo "Missing required file: $file" && exit 1
  fi
done

for file in $REQUIRED_FILES; do
  cp -r "handin/$file" src/dist
done

./src/dist/driver/driver

