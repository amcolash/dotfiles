#!/usr/bin/env bash
set -euo pipefail

# check if apt can be used
if [ ! $(command -v apt) ]; then
  echo "[!] apt is not installed. Skipping saving."
else
  echo "[+] Saving apt settings..."

  # move to the script directory
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  pushd "$SCRIPT_DIR" > /dev/null

  # TODO
  INSTALLED=$(comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u))
  echo "$INSTALLED" > apt.txt

  popd > /dev/null
fi