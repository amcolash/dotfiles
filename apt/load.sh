#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if apt can be used
if [ ! $(command -v apt) ]; then
  echo "[-] apt is not installed. Skipping loading."
  exit 0
fi

# check if user wants to load apt
read -p "Would you like to load $DIRNAME? [y/N] " do_load < /dev/tty
if [[ ! "$do_load" =~ ^[Yy]$ ]]; then
  echo "[-] Skipping $DIRNAME."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring apt packages"
cat apt.txt | xargs sudo apt install -m

popd > /dev/null
