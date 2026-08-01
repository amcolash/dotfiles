#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if settings can be loaded
if [ ! $(command -v dconf) ]; then
  echo "[-] dconf is not installed. Skipping loading."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

# detect OS
source ../scripts/os_detect.sh

echo "[+] Restoring shared dconf settings..."
if [ -d "shared" ]; then
  for file in shared/*.conf; do
    [ -e "$file" ] || continue
    base=$(basename "$file" .conf)
    dconf_path="/${base//./\/}/"
    echo "Loading $file into $dconf_path"
    dconf load "$dconf_path" < "$file"
  done
fi

if [ -n "$OS_PROFILE" ] && [ "$OS_PROFILE" != "unknown" ]; then
  echo "[+] Restoring ${OS_PROFILE} dconf settings..."
  if [ -d "$OS_PROFILE" ]; then
    for file in "$OS_PROFILE"/*.conf; do
      [ -e "$file" ] || continue
      base=$(basename "$file" .conf)
      dconf_path="/${base//./\/}/"
      echo "Loading $file into $dconf_path"
      dconf load "$dconf_path" < "$file"
    done
  else
    echo "[-] No OS-specific dconf settings found for profile: ${OS_PROFILE}."
  fi
fi

popd > /dev/null