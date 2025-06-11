#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# check if brew can be used
if [ ! $(command -v brew) ]; then
  echo "[-] brew is not installed. Skipping loading."
  exit 0
fi

# check if user wants to load brew
read -p "Would you like to load $SCRIPT_DIR? [y/N] " do_load < /dev/tty
if [[ ! "$do_load" =~ ^[Yy]$ ]]; then
  echo "[-] Skipping $SCRIPT_DIR."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring homebrew..."
cat brew.txt | xargs brew install

popd > /dev/null
