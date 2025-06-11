#!/usr/bin/env bash

# check if flatpak can be used
if [ ! $(command -v flatpak) ]; then
  echo "[!] flatpak is not installed. Skipping saving."
else
  echo "[+] Saving flatpak settings..."

  # move to the script directory
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  pushd "$SCRIPT_DIR" > /dev/null

  flatpak list --app --columns=origin --columns=application | awk '{print "flatpak install " $1,$2 " -y"}' > flatpaks.sh

  popd > /dev/null
fi
