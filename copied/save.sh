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
  if [ -r "$file" ]; then
    # We have read permission, normal copy works
    cp "$file" "$parent_dir"
  elif sudo test -f "$file"; then
    # File exists but we need root to read it
    sudo cp "$file" "$parent_dir"
  else
    # File doesn't exist at all
    echo "[!] Warning: $file does not exist. Skipping."
  fi
done

popd > /dev/null