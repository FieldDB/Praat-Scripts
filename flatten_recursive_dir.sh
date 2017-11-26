#!/bin/bash

# OPTIONAL_FILENAME='*.mp3'
OPTIONAL_FILENAME='*.*'
DIR=$1
echo "Looking in $DIR";

cd $DIR;
pwd
ls
find . -not -path '*/\.*' -mindepth 3 -exec bash -c '
  echo "Found $source";
  for source; do
    case $source in ./*/*)
      source=${source#./}
      target="${source//\//.}";
      echo "Moving $source to $target";
      # mv -i -- "$source" "$target";;
    esac
  done
' _ {} +
