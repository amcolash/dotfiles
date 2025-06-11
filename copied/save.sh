#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Copying files..."

for file in $(cat files.txt); do
  # make containing folder structure
  parent_dir="$(dirname "$file")"
  parent_dir="${parent_dir#/}" # remove leading slash of dir
  mkdir -p "$parent_dir"

  # copy the file
  sudo cp $file $parent_dir
done

popd > /dev/null