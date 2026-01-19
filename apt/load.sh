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

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring apt packages"
cat apt.txt | xargs sudo apt install -m

popd > /dev/null
