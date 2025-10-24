# This file is sourced before any other scripts in the .bashrc.d directory.

# Load linux homebrew
if [ -d /home/linuxbrew/.linuxbrew ] && [ ! -f /etc/NIXOS ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Disable ble.sh over ssh
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  DISABLE_BLESH=true
fi

if [ -f /etc/NIXOS ]; then
  DISABLE_ATUIN=true
  DISABLE_BLESH=true
fi
