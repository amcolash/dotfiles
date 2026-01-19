#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if user wants to load settings
read -p "Are you sure you want to copy special system files? [y/N] " do_load < /dev/tty
if [[ ! "$do_load" =~ ^[Yy]$ ]]; then
  echo "[-] Skipping $DIRNAME."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring copied files..."

for file in $(cat files.txt); do
# remove leading slash of dir
  local_file="${file#/}"

  # copy the file
  sudo cp $local_file $file
done

popd > /dev/null
