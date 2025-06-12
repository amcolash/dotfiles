#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Copying files (this might need root access)..."

for file in $(cat files.txt); do
  # make containing folder structure
  parent_dir="$(dirname "$file")"
  parent_dir="${parent_dir#/}" # remove leading slash of dir
  mkdir -p "$parent_dir"

  # copy each file, only use root if necessary
  if [ -f $file ]; then
    cp $file $parent_dir
  else
    sudo cp $file $parent_dir
  fi
done

popd > /dev/null