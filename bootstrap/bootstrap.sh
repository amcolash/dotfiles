#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CORE_SCRIPT="https://raw.githubusercontent.com/amcolash/dotfiles/refs/heads/main/bootstrap/bootstrap-core.sh"
SCRIPT_DOWNLOAD=0

# Grab the script if it doesn't exist
if ! [ -f bootstrap-core.sh ]; then
  echo "[+] Bootstrap script missing — downloading from Github"
  echo
  curl $CORE_SCRIPT -o bootstrap-core.sh
  chmod +x bootstrap-core.sh
  SCRIPT_DOWNLOAD=1
fi

# Detect NixOS
if [[ -f /etc/NIXOS ]]; then
  echo "[+] Detected NixOS — using nix-shell"

  exec nix-shell -p git stow openssh firefox --run "$SCRIPT_DIR/bootstrap-core.sh"
else
  echo "[+] Non-NixOS system — checking for required tools"

  for cmd in git stow ssh-keygen firefox; do
    if ! command -v "$cmd" >/dev/null; then
      echo "[!] Missing required command: $cmd"
      exit 1
    fi
  done

  bash "$SCRIPT_DIR/bootstrap-core.sh"
fi

if [ SCRIPT_DOWNLOAD == 1 ]; then
  echo
  echo "[+] Removing temporary bootstrap script"
  rm bootstrap-core.sh
fi
