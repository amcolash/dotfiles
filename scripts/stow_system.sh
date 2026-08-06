#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# stow from system -> system dirs, base is root
sudo /home/linuxbrew/.linuxbrew/bin/stow -R -d "$SCRIPT_DIR/.." -t / "system"

# Set user services
systemctl --user enable --now update-user-flatpaks.timer

# Set up system services
sudo systemctl --system enable --now update-system-flatpaks.timer

if [ $(command -v keylightc) ]; then
  sudo systemctl --system enable --now keylightc
else
  echo "keylightc not found, skipping enabling keylightc service"
fi

