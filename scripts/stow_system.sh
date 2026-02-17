#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ensure running as root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root: sudo $0"
  exit 1
fi

# stow from system -> system dirs, base is root
/home/linuxbrew/.linuxbrew/bin/stow -R -d "$SCRIPT_DIR/.." -t / "system"