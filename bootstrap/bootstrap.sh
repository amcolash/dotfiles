#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect NixOS
if [[ -f /etc/NIXOS ]] || command -v nixos-version >/dev/null; then
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
