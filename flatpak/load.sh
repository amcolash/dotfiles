#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if flatpak can be used
if [ ! $(command -v flatpak) ]; then
  echo "[-] flatpak is not installed. Skipping loading."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

# detect OS
source ../scripts/os_detect.sh

if [ -f "flatpaks_${OS_PROFILE}.sh" ]; then
  echo "[+] Restoring flatpaks for profile: ${OS_PROFILE}..."
  chmod +x "flatpaks_${OS_PROFILE}.sh"
  ./flatpaks_${OS_PROFILE}.sh
else
  echo "[-] No flatpak list found for profile: ${OS_PROFILE}. Skipping."
fi

popd > /dev/null
