#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if $DIR can be used
if [ ! $(command -v $DIR) ]; then
  echo "[-] $DIR is not installed. Skipping loading."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring $DIR"

# TODO

popd > /dev/null
