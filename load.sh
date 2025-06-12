#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Loading saved settings..."

for dir in */ ; do
  if [ -f "$dir/save.sh" ] && [ ! $dir == "templates/" ]; then
    pushd "$dir" > /dev/null
    ./load.sh
    popd > /dev/null
  fi
done

echo "[✓] Loading complete."