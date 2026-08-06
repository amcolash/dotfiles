#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# check if pacman can be used
if ! command -v pacman &> /dev/null; then
  echo "[-] pacman is not installed. Skipping loading."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Restoring pacman (native) packages..."
if [ -f pacman.txt ]; then
  if [ -s pacman.txt ]; then
    cat pacman.txt | xargs sudo pacman -S --needed --noconfirm
  else
    echo "[-] pacman.txt is empty. Skipping."
  fi
else
  echo "[!] pacman.txt not found! Please run save.sh first."
fi

if command -v paru &> /dev/null; then
  echo "[+] Restoring paru (AUR) packages..."
  if [ -f paru.txt ]; then
    if [ -s paru.txt ]; then
      cat paru.txt | xargs paru -S --needed --noconfirm
    else
      echo "[-] paru.txt is empty. Skipping."
    fi
  else
    echo "[!] paru.txt not found! Please run save.sh first."
  fi
else
  echo "[-] paru is not installed. Skipping AUR packages."
fi

popd > /dev/null
