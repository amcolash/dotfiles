#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if brew can be used
if [ ! $(command -v brew) ]; then
  echo "[-] brew is not installed. Skipping loading."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring homebrew..."

if [ "$(uname)" == "Darwin" ]; then
  cat brew_mac.txt | xargs brew install
  car brew_mac_cask.txt | xargs brew install --cask
else
  cat brew.txt | xargs brew install
fi

popd > /dev/null
