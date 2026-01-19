#!/usr/bin/env bash
set -euo pipefail

# check if $DIR can be used
if [ ! $(command -v $DIR) ]; then
  echo "[!] $DIR is not installed. Skipping saving."
  exit 0
fi

echo "[+] Saving $DIR settings..."

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

# TODO

popd > /dev/null