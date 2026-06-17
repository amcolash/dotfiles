#!/usr/bin/env bash
set -euo pipefail

# Move to wherever this script is actually located (if run locally)
if [[ -f "$0" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  pushd "$SCRIPT_DIR" > /dev/null
fi

CORE_SCRIPT="https://raw.githubusercontent.com/amcolash/dotfiles/refs/heads/main/bootstrap/bootstrap-core.sh"

if [ -f "bootstrap-core.sh" ]; then
  CORE_FILE="bootstrap-core.sh"
else
  echo "[+] Bootstrap script missing — downloading from Github"
  echo

  CORE_FILE=$(mktemp /tmp/bootstrap-core.XXXXXX.sh)

  # Clean up temp file when the script exits - regardless of success or error
  trap 'rm -f "$CORE_FILE"' EXIT

  curl -s "$CORE_SCRIPT" -o "$CORE_FILE"
  chmod +x "$CORE_FILE"
fi

# Detect NixOS
if [[ -f /etc/NIXOS ]]; then
  echo "[+] Detected NixOS — using nix-shell to bootstrap"
  nix-shell -p git stow openssh firefox unzip newt --run "$CORE_FILE"
else
  echo "[+] Non-NixOS system — running bootstrap normally"
  bash "$CORE_FILE"
fi

if [[ -f "$0" ]]; then
  popd > /dev/null
fi
