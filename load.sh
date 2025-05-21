#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Loading saved settings..."

for dir in */ ; do
  if [ -f "$dir/load.sh" ]; then

    read -p "Would you like to load $dir? [y/N] " do_load < /dev/tty
    if [[ "$do_load" =~ ^[Yy]$ ]]; then
      pushd "$dir" > /dev/null
      ./load.sh
      popd > /dev/null
    fi
  fi
done

echo "[✓] Loading complete."