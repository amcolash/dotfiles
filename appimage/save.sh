#!/usr/bin/env bash
set -euo pipefail

# update appman to latest
wget -q "https://raw.githubusercontent.com/ivan-hc/AM/main/APP-MANAGER" -O ~/.local/bin/appman && chmod a+x ~/.local/bin/appman

# check if appman is installed
if [ ! $(command -v appman) ]; then
  echo "[!] appman is not installed. Skipping saving."
  exit 0
fi

echo "[+] Saving appimages..."

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

# Extract just the app names from lines that start with " ◆ "
# Parse the format: " ◆ appname | version | type | size"
appman -f 2>/dev/null | \
  sed -n '/◆.*|.*|.*|/p' | \
  sed 's/^[[:space:]]*◆[[:space:]]*\([^[:space:]|]*\).*/\1/' | \
  sort > appimages.txt

popd > /dev/null
