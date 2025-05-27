#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

CORE_SCRIPT="https://raw.githubusercontent.com/amcolash/dotfiles/refs/heads/main/bootstrap/bootstrap-core.sh"
SCRIPT_DOWNLOAD=0

# Remove old bootstrap if not in git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "[*] Not in a git repository — removing old bootstrap script"
  rm -f bootstrap-core.sh
fi

# Grab the script if it doesn't exist
# TODO: Remove the download, just use curl + exec (?)
if ! [ -f bootstrap-core.sh ]; then
  echo "[+] Bootstrap script missing — downloading from Github"
  echo
  curl -s $CORE_SCRIPT -o bootstrap-core.sh
  chmod +x bootstrap-core.sh
  SCRIPT_DOWNLOAD=1
fi

# Detect NixOS
if [[ -f /etc/NIXOS ]]; then
  echo "[+] Detected NixOS — using nix-shell"

  exec nix-shell -p git stow openssh firefox unzip newt --run "$SCRIPT_DIR/bootstrap-core.sh"
else
  echo "[+] Non-NixOS system — running normally"
  bash "$SCRIPT_DIR/bootstrap-core.sh"
fi

if [ $SCRIPT_DOWNLOAD == 1 ]; then
  echo
  echo "[+] Removing temporary bootstrap script"
  rm bootstrap-core.sh
fi

popd > /dev/null
