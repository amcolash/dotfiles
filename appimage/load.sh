#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# update appman to latest
wget -q "https://raw.githubusercontent.com/ivan-hc/AM/main/APP-MANAGER" -O ~/.local/bin/appman && chmod a+x ~/.local/bin/appman

# check if appimage can be used
if [ ! $(command -v appman) ]; then
  echo "[-] appman is not installed. Skipping loading."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring appimages"

cat appimages.txt | xargs appman install
appman -u

popd > /dev/null
