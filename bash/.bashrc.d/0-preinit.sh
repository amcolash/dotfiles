# This file is sourced before any other scripts in the .bashrc.d directory.

# Load linux homebrew
if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Disable ble.sh over ssh
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  DISABLE_BLESH=true
fi
