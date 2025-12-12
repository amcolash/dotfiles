# This file is sourced before any other scripts in the .bashrc.d directory.

# Load linux homebrew
if [ -d /home/linuxbrew/.linuxbrew ] && [ ! -f /etc/NIXOS ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

