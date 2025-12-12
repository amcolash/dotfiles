#!/usr/bin/env bash
set -euo pipefail

# check if brew can be used
if [ ! $(command -v brew) ]; then
  echo "[!] brew is not installed. Skipping saving."
else
  echo "[+] Saving brew settings..."

  # move to the script directory
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  pushd "$SCRIPT_DIR" > /dev/null

  if [ "$(uname)" == "Darwin" ]; then
    brew list --installed-on-request > brew_mac.txt
  else
    brew list --installed-on-request > brew.txt
  fi

  popd > /dev/null
fi
