#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# check if settings can be loaded
if [ ! $(command -v dconf) ]; then
  echo "[-] dconf is not installed. Skipping loading."
  exit 0
fi

# check if user wants to load settings
read -p "Would you like to load $SCRIPT_DIR? [y/N] " do_load < /dev/tty
if [[ ! "$do_load" =~ ^[Yy]$ ]]; then
  echo "[-] Skipping $SCRIPT_DIR."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring dconf settings..."
for file in *.conf; do
  base=$(basename "$file" .conf)

  # Convert filename back to dconf path and add trailing slash
  dconf_path="/${base//./\/}/"

  echo "Loading $file into $dconf_path"
  dconf load "$dconf_path" < "$file"
done

popd > /dev/null