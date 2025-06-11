#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

if [ -d ~/.local/share/cinnamon ]; then
  echo "[+] Saving installed Cinnamon spices..."

  ls ~/.local/share/cinnamon/applets    > "applets.txt"
  ls ~/.local/share/cinnamon/extensions > "extensions.txt"
else
  echo "[!] No Cinnamon spices found"
fi

popd > /dev/null