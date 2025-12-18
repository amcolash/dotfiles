#!/usr/bin/env bash

pushd ../ > /dev/null

# usage stub_save_load.sh <dir>
if [ -z "$1" ]; then
  echo "Usage: $0 <dir>"
  popd > /dev/null
  exit 1
fi

mkdir -p "$1"

# create save.sh
if [ ! -f "$1/save.sh" ]; then
  cp templates/save.sh "$1/save.sh"
  sed -i "s|\$DIR|$1|g" "$1/save.sh"

  chmod +x "$1/save.sh"
fi

# create load.sh
if [ ! -f "$1/load.sh" ]; then
  cp templates/load.sh "$1/load.sh"
  sed -i "s|\$DIR|$1|g" "$1/load.sh"

  chmod +x "$1/load.sh"
fi

popd > /dev/null
